extends NavdiSolePlayerBasics

enum { RESPAWNBUF, DISAPPEARINGBUF, }

var jumped : bool = false

func disappear() -> void:
	if not bufs.has(DISAPPEARINGBUF):
		bufs.on(DISAPPEARINGBUF)

func _ready() -> void:
	super._ready()
	bufs.setup_bufons([
		RESPAWNBUF, 55,
		DISAPPEARINGBUF, 30,
	])
	bufs.on(RESPAWNBUF)

func _physics_process(_delta: float) -> void:
	if position.x <= -5: bufs.on(RESPAWNBUF)
	if position.x >= 105: bufs.on(RESPAWNBUF)
	if position.y >= 105: bufs.on(RESPAWNBUF)
	
	var dpad := Pin.get_dpad()
	var onfloor := is_on_floor()
	if onfloor: jumped = false
	if bufs.has(DISAPPEARINGBUF):
		vx = 0; vy = 0; dpad.x = 0;
	tow_vx(dpad.x, 0.5, 0.1)
	tow_gravity(1.0, 0.0155, jumped and Pin.get_jump_held(), 0.035)
	if Pin.get_jump_hit(): bufs.on(JUMPBUF)
	if bufs.has(RESPAWNBUF):
		position.x = 50; position.y = 55; faceleft = false;
		vx = 0; vy = 0; dpad.x = 0; bufs.clr(JUMPBUF);
	apply_velocities()
	if bufs.has(DISAPPEARINGBUF):
		if bufs.read(DISAPPEARINGBUF) == 1:
			queue_free()
		else:
			spr.visible = bufs.read(DISAPPEARINGBUF) % 5 <3
	elif bufs.has(RESPAWNBUF):
		spr.setup([0,0,74,75,76,76],10)
		if bufs.read(RESPAWNBUF) == 1:
			vy = -1.0 # jumped = false
			spr.show()
		else:
			spr.visible = bufs.read(RESPAWNBUF) % 5 <3
	elif !onfloor:
		spr.setup([12,13,14,12,12,],8)
	elif dpad.x:
		spr.setup_forcechangeindex([10,11],8)
	else:
		spr.setup_trywaitformatch([10],0)
	if bufs.try_eat([FLORBUF,JUMPBUF,]):
		vy = -1.0
		jumped = true
	
	
