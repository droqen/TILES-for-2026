extends Node

@export var editor_dream : NavdiDream
@export var first_dream : NavdiDream
@export var test_first : bool = false

func _ready() -> void:
	if OS.has_feature("editor") and not test_first:
		print("loading editor dream..")
		Dreamer.dream(editor_dream)
	else:
		print("loading first dream.. %s" % first_dream.resource_path)
		Dreamer.dream(first_dream)
