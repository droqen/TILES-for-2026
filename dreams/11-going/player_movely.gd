extends NavdiSolePlayerBasics

func _physics_process(_delta: float) -> void:
	var dpad := Pin.get_dpad()
	tow_vx(dpad.x, 1.0, 0.4)
	vy = move_toward(vy, dpad.y, 0.4)
	self.apply_velocities()
