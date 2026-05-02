extends NavdiSolePlayerBasics

enum {
	SHOTHITBUF,
	SHOTFLASHBUF,
	SHOTCOOLDOWNBUF,
}

@onready var stage = get_parent()

var jetpacking := false

func _ready() -> void:
	super._ready()
	bufs.setup_bufons([
		FLORBUF,8,
		SHOTHITBUF,4,
		SHOTFLASHBUF,8,
		SHOTCOOLDOWNBUF,15,
	])

func _physics_process(_delta: float) -> void:
	var dpad := Pin.get_dpad()
	var jumpheld := Pin.get_jump_held()
	var onflor := is_on_floor()
	if jetpacking and not jumpheld: jetpacking = false
	if Pin.get_jump_hit():
		bufs.on(JUMPBUF)
		if not bufs.has(FLORBUF):
			jetpacking = true
			if vy > 0: vy *= 0.5
	if vy > 0 and jumpheld: jetpacking = true
	if Pin.get_offhand_hit(): bufs.on(SHOTHITBUF)
	tow_vx(dpad.x,
		0.5 if onflor else 0.7,
		0.2 if onflor else 0.05,
		not Pin.get_offhand_held())
	if jetpacking: vy = move_toward(vy, -0.5, 0.07)
	tow_gravity(1.5,0.020,jumpheld,0.030)
	if not onflor and bufs.read(FLORBUF)>4: vy = -0.05
	if onflor: vy = 0.0
	apply_velocities()
	if bufs.has(SHOTFLASHBUF):
		spr.setup([13],0)
	elif bufs.has(TURNBUF):
		spr.setup([12],0)
	elif!onflor:
		if jetpacking:
			spr.setup([16,17,18],10)
		else:
			spr.setup([11],0)
	elif dpad.x:
		spr.setup_forcechangeindex([11,10],8)
	else:
		spr.setup_trywaitformatch([10],0)
	if bufs.try_eat([JUMPBUF,FLORBUF]): vy = -1
	if not bufs.has(SHOTCOOLDOWNBUF) and (bufs.try_eat([SHOTHITBUF]) or Pin.get_offhand_held()):
		bufs.on(SHOTFLASHBUF)
		bufs.on(SHOTCOOLDOWNBUF)
		stage.spawn_pbullets(self)
		vx -= facedir * 0.1
	
