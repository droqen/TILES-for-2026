extends Node2D

var life : int = 20

func _physics_process(_delta: float) -> void:
	scale *= 0.9
	rotation += 0.05
	life -= 1
	if life < 0 : queue_free()
