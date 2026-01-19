extends Resource
class_name NavdiDream
@export var packed_scene : PackedScene = null # default is null.
func _to_string() -> String:
	return "NavdiDream@%s" % resource_path
