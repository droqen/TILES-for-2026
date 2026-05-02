extends Node2D

@onready var rate : float = randf_range(0.09,0.11)

var x : int
var y : int

func _ready() -> void:
	$spr.scale.x = 0.0
	$spr.scale.y = randf_range(1.7,2.3)

func _physics_process(_delta: float) -> void:
	$spr.scale.x = lerp($spr.scale.x, 1.0, rate)
	$spr.scale.y = lerp($spr.scale.y, 1.0, rate)

func setup(_x:int, _y:int, pos:Vector2):
	x = _x
	y = _y
	position = pos
	return self

func owie() -> void:
	get_parent().get_parent().spawn_edeath(position)
	queue_free()
