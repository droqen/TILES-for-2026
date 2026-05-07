extends Node2D

const roomsize_tiles : Vector2i = Vector2i(25,13)
const roomsize_pixels : Vector2i = roomsize_tiles * 10
var room_coords : Vector2i

func loadroom() -> void:
	print("copy", Rect2i(room_coords * roomsize_tiles, roomsize_tiles))
	$stage/Maze.copy_from(
		$v.exiled_maze,
		Rect2i(room_coords * roomsize_tiles, roomsize_tiles),
	)

func _ready() -> void:
	loadroom.call_deferred()
