extends Node

@export var original : Node2D
@export var duplicount : int = 19
@export var duplidiff : Vector2 = Vector2(0,10)
func _ready() -> void:
	for i in duplicount:
		var dupe = original.duplicate()
		dupe.position += duplidiff * (i+1)
		original.get_parent().add_child(dupe)
	
