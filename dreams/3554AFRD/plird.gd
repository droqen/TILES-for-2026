extends NavdiSolePlayerBasics

func _physics_process(_delta: float) -> void:
	var dpad := Pin.get_dpad()
	tow_vx(dpad.x, 0.5, 0.1)
	apply_velocities()
