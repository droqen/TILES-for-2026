extends Node

func _physics_process(_delta: float) -> void:
	var r = $NavdiViewRect
	r.position = lerp(r.position, Vector2(Vector2i($"../player".position)) - r.size/2, 0.1)
