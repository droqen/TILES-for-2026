extends NavdiSolePlayerBasics

func _physics_process(_delta: float) -> void:
	var dpad := Pin.get_dpad()
	var onfloor := is_on_floor()
	var duck := onfloor and (Pin.get_dpad().y > 0 or Pin.get_plant_held())
	if duck and dpad.x:
		facedir = dpad.x
		dpad.x = 0
	if Pin.get_jump_hit(): bufs.on(JUMPBUF)
	if duck:  tow_vx(      0, 1.0, 0.05, false )
	else:     tow_vx( dpad.x, 1.0, 0.1 ,       )
	tow_gravity(0.8, 0.01, Pin.get_jump_held(), 0.05)
	apply_velocities()
	
	if !onfloor:
		if bufs.has(TURNBUF):
			spr.setup([21],0)
		else:
			spr.setup([11],0)
	elif duck:
		if bufs.has(TURNBUF):
			spr.setup([22],0)
		else:
			spr.setup([12],0)
	else:
		if bufs.has(TURNBUF):
			spr.setup([20],0)
		elif dpad.x:
			spr.setup_forcechangeindex([11,10],10)
		else:
			spr.setup_trywaitformatch([10],0)
	
	if bufs.try_eat([JUMPBUF, FLORBUF]): vy = -1.0
