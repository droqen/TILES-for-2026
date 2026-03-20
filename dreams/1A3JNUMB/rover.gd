extends NavdiSolePlayerBasics

var flashing = 0

func _ready() -> void:
	super._ready()
	bufs.setup_bufons([FLORBUF,8,])

func _physics_process(_delta: float) -> void:
	if flashing > 0:
		vx *= 0.5
		flashing -= 1
		spr.visible = flashing % 5 < 3
	else:
		flashing = 0
	if Pin.get_jump_hit(): bufs.on(JUMPBUF)
	var dpad = Pin.get_dpad()
	var onfloor := is_on_floor()
	var skidding : bool = (onfloor
		and dpad.x * vx < 0
		and abs(vx) > 0.5)
	if skidding:
		self.facedir = dpad.x
		vx *= 0.96
	elif onfloor:
		tow_vx(dpad.x, 1.4, 0.07)
		vx *= 0.98
	else: # in air
		if dpad.x:
			tow_vx(dpad.x, 1.4, 0.03)
		else:
			vx *= 0.99
		#vx *= 0.99
	tow_gravity(2.0,
		0.03, Pin.get_jump_held(),
		+.04) # fastfall.
	apply_velocities()
	if !onfloor:
		spr.setup([16])
	elif bufs.has(LANDBUF):
		spr.setup([15])
	elif bufs.has(TURNBUF):
		spr.setup_trywaitformatch([13])
	elif skidding:
		spr.setup([14])
	elif dpad.x:
		spr.setup_forcechangeindex([10,11,10,12])
	else:
		spr.setup_trywaitformatch([10])
	if bufs.try_eat([JUMPBUF, FLORBUF]):
		vy = -1.2
