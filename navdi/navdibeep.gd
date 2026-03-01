extends Node
class_name NavdiBeep

@export var url : String

func _ready() -> void:
	add_to_group(NavdiBeeper.BEEPER_BEEP_GROUP)

func get_beepbox_url() -> String:
	return url
