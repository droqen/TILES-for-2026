extends ReferenceRect

func _ready() -> void:
	Dreamer.cam.dreamview_rect = self.get_rect()
	Dreamer.cam.snap_to_target()
