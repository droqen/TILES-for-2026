extends Node2D

const IS_ROVER = true

signal opened
signal hidestarted
signal hidestopped

@onready var label : Label = $Label
#var label_bottom_y : int = -1
@onready var labelcolour : Color = label.modulate

var justflashed : bool = false
var typing : bool = false
var untyping : bool = true

func _ready() -> void:
	#label_bottom_y = label.get_visible_line_count()
	label.visible_characters = 0
	$playertouch.area_entered.connect(func(_plr):
		typing = true; untyping = false;
	)
	$playertouch.area_exited.connect(func(_plr):
		typing = false;
	)
	$playernear.area_exited.connect(func(_plr):
		typing = false;
		if label.visible_characters > 0 and not untyping:
			hidestarted.emit()
		untyping = true
	)
func _physics_process(_delta: float) -> void:
	if typing:
		if not label.visible or label.visible_characters != len(label.text):
			opened.emit()
			label.show()
			label.modulate = Color.WHITE
			label.visible_characters = len(label.text)
			await get_tree().create_timer(0.1).timeout
			if is_instance_valid(label):
				label.modulate = labelcolour
	elif untyping:
		if label.visible_characters > 0:
			label.visible_characters -= 1
			if label.visible_characters == 0:
				hidestopped.emit()
