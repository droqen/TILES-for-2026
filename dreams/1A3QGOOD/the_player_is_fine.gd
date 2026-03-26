extends NavdiSolePlayerBasics

func _physics_process(_delta: float) -> void:
	var dpad := Pin.get_dpad()
	var onfloor := is_on_floor()
	if Pin.get_jump_hit(): bufs.on(JUMPBUF)
	tow_vx(dpad.x, 0.5, 0.1)
	tow_gravity(1.6, 0.09)
	apply_velocities()
	if bufs.has(TURNBUF):
		spr.setup([21])
	elif not onfloor:
		spr.setup([13])
	elif bufs.has(LANDBUF):
		spr.setup([20])
	elif dpad.x:
		spr.setup_forcechangeindex([10,11,12,13,],8)
	else:
		spr.setup([10])
	if bufs.try_eat([JUMPBUF,]):
		vy = -1.5
	position.x = fposmod(position.x, 200)
	if position.y < 0: position.y = 0
	else: position.y = fposmod(position.y, 180)
