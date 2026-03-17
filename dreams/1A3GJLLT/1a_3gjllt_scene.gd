extends Node2D

enum { FINE, DOWNED }
var status = FINE

@onready var bahharat = $bahharat
@onready var bgm = $bgm

func _physics_process(_delta: float) -> void:
	match status:
		FINE:
			if bahharat.__injured > 0:
				bgm.pause()
				status = DOWNED
		DOWNED:
			if bahharat.__injured <= 0:
				bgm.play()
				status = FINE
