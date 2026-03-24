extends NavdiSolePlayerBasics

var doing_something_weird := false

func _ready() -> void:
	super._ready()
	bufs.setup_bufons([JUMPBUF, 9])

func _physics_process(_delta: float) -> void:
	var dpad := Pin.get_dpad()
	var duck := dpad.y > 0 or Pin.get_plant_held()
	if Pin.get_jump_hit() and not bufs.has(JUMPBUF):
		bufs.on(JUMPBUF)
	tow_vx(dpad.x, 0.25 if duck else 0.5, 0.05)
	apply_velocities()
	position.x = clamp(position.x, -10, 170)
	if bufs.has(JUMPBUF):
		spr.setup([15])
		if bufs.read(JUMPBUF) <3:
			spr.position.y = 0
		else:
			spr.position.y = -1
	else:
		spr.position.y = 0
		if bufs.has(TURNBUF) and not duck:
			spr.setup([12])
		elif dpad.x:
			if duck:
				spr.setup_forcechangeindex([23,24,25,13],7)
			else:
				spr.setup_forcechangeindex([10,11],10)
		else:
			if duck:
				spr.setup([13])
			else:
				spr.setup_trywaitformatch([10])
				
	doing_something_weird = (
		abs(position.x-75) < (15 if dpad.x else 9)
		or
		bufs.has(JUMPBUF)
	)
