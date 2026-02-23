extends ReferenceRect
class_name DreamyCameraRect

func _ready() -> void:
	Dreamer.cam.zoom_levels_int_only = true
	Dreamer.cam.dreamview_rect = self.get_rect()
	Dreamer.cam.snap_to_target()
