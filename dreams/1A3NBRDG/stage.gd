extends Node2D

@onready var vessel : NavdiVessel = $"../NavdiVessel"
@onready var maze : Maze = $Maze
var room : Vector2i = Vector2i(0,0)
@warning_ignore("integer_division")
@onready var ROOMSIZE : Vector2i = vessel.vessel_room_size / 10

func loadroom() -> void:
	maze.copy_from(
		vessel.get_maze(),
		Rect2i(room * ROOMSIZE, ROOMSIZE),
		Vector2i(0,0),
		true,
	)

func _ready() -> void:
	loadroom.call_deferred()
