extends Node2D

const IS_ROVER = true

@onready var label : Label = $Label
var label_bottom_y : int = -1

var typing : bool = false
var untyping : bool = true

func _ready() -> void:
	label_bottom_y = label.get_visible_line_count()
	label.visible_characters = 0
	$playertouch.area_entered.connect(func(_plr):
		typing = true; untyping = false;
	)
	$playertouch.area_exited.connect(func(_plr):
		typing = false;
	)
	$playernear.area_exited.connect(func(_plr):
		typing = false; untyping = true;
	)
func _physics_process(_delta: float) -> void:
	if typing:
		if label.visible_characters < len(label.text):
			label.visible_characters += 1
	if untyping:
		if label.visible_characters > 0:
			label.visible_characters -= 1
