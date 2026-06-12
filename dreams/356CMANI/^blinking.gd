extends Node

var _t : int = 0
func _physics_process(_delta: float) -> void:
	_t = (_t + 1) % 100
	get_parent().visible = _t < 50
