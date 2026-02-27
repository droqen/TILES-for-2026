extends Node2D

func _physics_process(_delta: float) -> void:
	var dpad = Pin.get_dpad()
	position += dpad as Vector2
