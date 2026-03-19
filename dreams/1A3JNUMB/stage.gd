extends Node2D

@onready var maze : Maze = $Maze
@onready var vessel : NavdiVessel = $"../NavdiVessel"

var roomcoords : Vector2i = Vector2i(0,0)

func _ready() -> void:
	loadroom.call_deferred()
func loadroom() -> void:
	@warning_ignore("integer_division")
	maze.copy_from(
		vessel.get_maze(),
		Rect2i(
			roomcoords,
			vessel.vessel_room_size/10
		)
	)
	vessel.spawn_exiles_by_roomcoords(roomcoords, $Objects, true)
