extends Node2D

@onready var startpos := position
var t := 0.0

func _physics_process(_delta: float) -> void:
	t += 0.01
	position.y = startpos.y + sin(t) * 2
