
extends Node2D

@onready var vessel : NavdiVessel = $"../NavdiVessel"
@onready var maze : Maze = $Maze
@onready var tinyman = $tinyguy
var roomcell : Vector2i = Vector2i(
	-1,0
)
func loadroom() -> void:
	@warning_ignore("integer_division")
	var room_size_int := Vector2i(vessel.vessel_room_size) / 10
	maze.copy_from(
		vessel.get_maze(),
		Rect2i(
			roomcell * room_size_int,
			room_size_int),
	)
	vessel.spawn_exiles_by_roomcoords(
		roomcell,
		$Exiles,
		true
	)
	if Dreamer.r("scored_by_king"):
		$zero_score.show()
func _ready() -> void:
	loadroom.call_deferred()
func _physics_process(_delta: float) -> void:
	if is_instance_valid(tinyman):
		if maze.get_cell_tid(maze.local_to_map(tinyman.position)) == 99:
			tinyman.queue_free()
		var traveldir := NavdiGenUtil.gen_oobdir(
			tinyman.position,
			NavdiGenUtil.shrink_rect2i(
				Rect2i(Vector2i(0,0,),vessel.vessel_room_size),
				2,
			)
		)
		if traveldir:
			roomcell += traveldir
			tinyman.position.x -= (traveldir.x
			 * (vessel.vessel_room_size.x - 5))
			tinyman.position.y -= (traveldir.y
			 * (vessel.vessel_room_size.y - 5))
			loadroom()
