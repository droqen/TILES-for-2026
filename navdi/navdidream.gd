extends Resource
class_name NavdiDream
@export var packed_scene : PackedScene = null # default is null.
@export var beepbox_url : String = ""
func _to_string() -> String:
	return "NavdiDream@%s" % resource_path
func get_pyxel() -> Texture2D:
	print("ok")
	return null
