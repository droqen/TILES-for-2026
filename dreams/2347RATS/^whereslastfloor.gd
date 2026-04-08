extends ColorRect

func _physics_process(_delta: float) -> void:
	position = get_parent().rat_last_floor_position + Vector2(-5,-5)
