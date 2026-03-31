extends NavdiSolePlayerBasics

var airjumps := 0
var flipping := false
var ducking := false

func _physics_process(_delta: float) -> void:
	var dpad := Pin.get_dpad()
	var onfloor := is_on_floor()
	if onfloor: airjumps = 1; flipping = false;
	if Pin.get_jump_hit(): bufs.on(JUMPBUF)
	ducking = onfloor and Pin.get_plant_held()
	if ducking: dpad.x = 0
	tow_vx(dpad.x, 0.5, 0.2)
	tow_gravity(0.5, 0.05)
	apply_velocities()
	if flipping: spr.setup([12,13,14,11],5)
	elif !onfloor: spr.setup([11])
	elif ducking: spr.setup([23])
	elif dpad.x: spr.setup_forcechangeindex([10,11],8)
	else: spr.setup_trywaitformatch([10])
	if bufs.try_eat([JUMPBUF, FLORBUF]):
		vy = -0.6
		if ducking:
			airjumps = 0
			flipping = true
			vy = -1.05
	elif !onfloor and airjumps > 0 and bufs.try_eat([JUMPBUF]):
		airjumps -= 1
		flipping = true
		vy = -0.9
