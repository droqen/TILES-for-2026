extends Node2D
@onready var vessel : NavdiVessel = $"../NavdiVessel"
@onready var player := $minotaur
@onready var maze := $Maze
@export var roomcoords := Vector2i(2,0)
const ROOMSIZE := Vector2i(10,10)
func loadroom() -> void:
	maze.copy_from(
	vessel.get_maze(),
	Rect2i(roomcoords*ROOMSIZE,ROOMSIZE))
	vessel.spawn_exiles_by_roomcoords(roomcoords, $Spawned, true)
func _ready() -> void:
	loadroom.call_deferred()
func _physics_process(_delta: float) -> void:
	if is_instance_valid(player):
		var region : Rect2i = NavdiGenUtil.shrink_rect2i(
				Rect2i(0,0,100,100), 1)
		var oobdir := NavdiGenUtil.gen_oobdir(player.position, region)
		if oobdir:
			player.position -= oobdir * region.size * 0.98
			roomcoords += oobdir
			loadroom()
		
		if maze.get_cell_tid(maze.local_to_map(player.position)) == 99:
			player.queue_free()
