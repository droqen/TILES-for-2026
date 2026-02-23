extends Node

@export var first_dream : NavdiDream

func _ready() -> void:
	Effects.set_blur(0.25)
	Dreamer.zoom_changed.connect(func(z):Effects.set_screenscale(z))
	Dreamer.dream(first_dream)
