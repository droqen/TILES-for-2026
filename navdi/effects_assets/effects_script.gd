extends Node

@export var blur_color_rects : Array[ColorRect]
@export var blurease_params : NavdiEaseParams = NavdiEaseParams.new() # default params
@onready var blurease : NavdiEase = NavdiEase.new(
).setup_params(blurease_params).setup_value(10).setup_velocity(-5)

var _internal_screenscale : float

func set_screenscale(ss:float):
	if _internal_screenscale != ss:
		_internal_screenscale = ss
		_update_blur_shader(blurease.value)

func set_blur(blur_amount):
	blurease.target = blur_amount

func _ready() -> void:
	blurease.value_changed.connect(_update_blur_shader)

func _physics_process(_delta: float) -> void:
	blurease.update()

func _update_blur_shader(blur_amount_base: float) -> void:
	var blur_amount : float = blur_amount_base * _internal_screenscale
	for blur_color_rect in blur_color_rects:
		(blur_color_rect.material as ShaderMaterial).set_shader_parameter(
			"blur_amount", blur_amount
		)
