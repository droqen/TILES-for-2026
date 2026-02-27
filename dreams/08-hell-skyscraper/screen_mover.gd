extends Node2D

var cell : Vector2i = Vector2i.ZERO
var target : Vector2 = Vector2.ZERO

@export var viewrect : NavdiViewRect

func _physics_process(_delta: float) -> void:
		var dpad_tap : Vector2i = Pin.get_dpad_tap()
		if dpad_tap and position == target:
			cell += dpad_tap
			target = Vector2(cell) * 100
		position.x = move_toward(position.x, target.x, 1)
		position.y = move_toward(position.y, target.y, 1)
		viewrect.move_to(position)
