extends NavdiSolePlayerBasics

func _physics_process(_delta: float) -> void:
	var dpad := Pin.get_dpad()
	if Pin.get_jump_hit(): bufs.on(JUMPBUF)
	var onfloor := is_on_floor()
	tow_vx(dpad.x, 1.0, 0.1)
	tow_gravity(1.5, 0.02, Pin.get_jump_held(), 0.05)
	apply_velocities()
	if bufs.has(TURNBUF):
		spr.setup([13])
	elif !onfloor:
		spr.setup([12])
	elif dpad.x:
		spr.setup_forcechangeindex([11,10],10)
	else:
		spr.setup_trywaitformatch([10])
		### puts hands down slowly
		#if spr.frame == 20: spr.setup([20])
		#else: spr.setup_trywaitformatch([
			#10,10,10,10,10,10,10,10,10,10,10,10,
			#10,10,10,10,10,10,10,10,10,10,10,10,
			#23,23,23,23,23,
			#22,22,21,20,],5)
	if bufs.try_eat([JUMPBUF,FLORBUF]):
		vy = -1.5
