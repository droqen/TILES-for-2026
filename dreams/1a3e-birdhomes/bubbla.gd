extends Node2D

const BUBBLE_PFB = preload("res://dreams/1a3e-birdhomes/bubble_spawned.tscn")

@onready var player = $"../birdplayer"

var delay_inbetween : int = 0

func _ready() -> void:
	delay_inbetween = randi_range(10,150)
func _physics_process(_delta: float) -> void:
	if delay_inbetween > 0:
		delay_inbetween -= 1
	else:
		(Dreamer
			.spawn(BUBBLE_PFB, self)
			.setup_pos(Vector2(randf_range(10,220),166))
		).n.watch_player(player)
		delay_inbetween = randi_range(500,1000)
	
