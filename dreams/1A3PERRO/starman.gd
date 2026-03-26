extends NavdiSolePlayerBasics

func _physics_process(_delta: float) -> void:
	var dpad := Pin.get_dpad()
	if Pin.get_jump_hit(): bufs.on(JUMPBUF)
	var onfloor := is_on_floor()
	var duck := onfloor and dpad.y > 0
	tow_vx(dpad.x, 0.5 if duck else 1.0, 0.1)
	tow_gravity(1.5, 0.02, Pin.get_jump_held(), 0.05)
	apply_velocities()
	if bufs.has(TURNBUF):
		if not duck:
			spr.setup([13])
	elif !onfloor:
		spr.setup([15,16],
			10
			-(3 if vy < 0 and Pin.get_jump_held() else 0)
			-(2 if dpad.x else 0)
		)
	elif bufs.has(LANDBUF):
		if duck:
			spr.setup([11])
		else:
			spr.setup([25])
	elif dpad.x:
		if duck:
			spr.setup_forcechangeindex([11,18],15)
		else:
			spr.setup_forcechangeindex([11,10],10)
	else:
		if duck:
			spr.setup_trywaitformatch([11])
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
