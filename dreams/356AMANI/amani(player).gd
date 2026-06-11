extends NavdiSolePlayerBasics

@onready var maze : Maze = $"../Maze"

func _physics_process(_delta: float) -> void:
	var onflor := is_on_floor()
	var dpad := Pin.get_dpad()
	tow_vx(dpad.x, 0.5, 0.05)
	tow_gravity(1.0, 0.015, Pin.get_jump_held(), 0.015)
	if Pin.get_jump_hit():
		if vy >= 0.5 or onflor:
			vy = -1
			onflor = false
		else:
			vy = min(-0.25, lerp(vy,-1.0,0.1))
	apply_velocities()
	if onflor:
		if bufs.has(TURNBUF):
			spr.setup([40],0)
		elif bufs.has(LANDBUF):
			spr.setup([31],0)
		elif dpad.x:
			spr.setup_forcechangeindex([30,31,32,33],10)
		elif vx == 0:
			spr.setup([10,11],20)
	else:
		if vy < -0.2:
			spr.setup([20],0)
		elif vy < 0.4:
			spr.setup([21],0)
		else:
			spr.setup([22],0)
	
