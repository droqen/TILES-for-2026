extends NavdiSolePlayerBasics

var phase := 0

func _physics_process(_delta: float) -> void:
	var dpad := Pin.get_dpad()
	tow_vx(dpad.x, 1, 9)
	vy = move_toward(vy, dpad.y, 9)
	if dpad:
		spr.setup_forcechangeindex([21,20,22,20],10)
	else:
		spr.setup_trywaitformatch([20])
	if visible:
		if spr.ani_subindex %5 == 4:
			apply_velocities()
		
