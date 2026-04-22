@tool
extends Node2D

@export var text : String
func _physics_process(_delta: float) -> void:
	if text != $Label.text:
		$Label.text = text
		#var xoffset = floor(len(text)*0.5) * -5
		#$ColorRect.position.x = xoffset
		#$Label.position.x = xoffset
		$ColorRect.size.x = 5 * len(text)
