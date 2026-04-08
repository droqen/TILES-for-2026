extends ColorRect

func _physics_process(_delta: float) -> void:
	if get_parent().onfloor:
		color = Color.RED
	else:
		color = Color.WHITE
