extends Node

func _ready() -> void:	
	Effects.set_blur(0)
	Effects.blurease.setup_value.call_deferred(0.0)
	for child in Effects.get_children():
		if child.name.begins_with("Blur") or true:
			child.hide()
func _physics_process(_delta: float) -> void:
	pass
