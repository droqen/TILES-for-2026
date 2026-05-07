extends Node2D

const roomsize_tiles : Vector2i = Vector2i(25,13)
const roomsize_pixels : Vector2i = roomsize_tiles * 10
const roomrect_pixels : Rect2i = Rect2i(Vector2i(0,0), roomsize_pixels)
var room_coords : Vector2i = Vector2i(0,0)

func loadroom() -> void:
	#print("copy", Rect2i(room_coords * roomsize_tiles, roomsize_tiles))
	$stage/Maze.copy_from(
		$v.exiled_maze,
		Rect2i(room_coords * roomsize_tiles, roomsize_tiles),
	)
	$v.spawn_exiles_by_roomcoords(room_coords, $stage/exiles, true)

func _ready() -> void:
	loadroom.call_deferred()

func _physics_process(_delta: float) -> void:
	var traveldir : Vector2i = (NavdiGenUtil
		.gen_oobdir($stage/lion.position, roomrect_pixels, -1))
	if traveldir:
		room_coords += traveldir
		print("travel",traveldir)
		$stage/lion.position -= Vector2((roomsize_pixels - Vector2i(4,4)) * traveldir)
		loadroom()
		$stage/Maze.update_internals() # SO IMPORTANT.
