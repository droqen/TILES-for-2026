extends Node

func _ready() -> void:
	Dreamer.cam.set_dreamview_size(Vector2(100, 100))
func _physics_process(_delta: float) -> void:
	Dreamer.cam.set_dreamview_focus(get_parent().position)
