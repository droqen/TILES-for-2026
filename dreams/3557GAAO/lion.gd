extends NavdiSolePlayerBasics

func _physics_process(_delta: float) -> void:
	var dpad := Pin.get_dpad()
	var onflor := is_on_floor()
	if Pin.get_jump_hit(): bufs.on(JUMPBUF)
	tow_vx(dpad.x, 0.8, 0.1)
	tow_gravity(1.2, .035, Pin.get_jump_held(), .066)
	apply_velocities()
	# spr
	if not onflor:
		spr.setup([11],0)
	elif dpad.x:
		spr.setup_forcechangeindex([10,11],12)
	else:
		spr.setup_trywaitformatch([10],0)
	
	if bufs.try_eat([JUMPBUF,FLORBUF]):
		vy = -1.7
