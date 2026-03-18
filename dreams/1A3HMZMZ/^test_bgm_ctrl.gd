extends Node

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_right"):
		get_parent().play()
	if Input.is_action_just_pressed("ui_left"):
		get_parent().stop()
	if Input.is_action_just_pressed("ui_up"):
		get_parent().tempo += 10
	if Input.is_action_just_pressed("ui_down"):
		get_parent().tempo -= 10
