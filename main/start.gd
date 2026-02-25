extends Node

@export var editor_dream : NavdiDream
@export var first_dream : NavdiDream
@export var test_first : bool = false

func _ready() -> void:
	if OS.has_feature("editor") and not test_first:
		Dreamer.dream(editor_dream)
	else:
		Dreamer.dream(first_dream)
