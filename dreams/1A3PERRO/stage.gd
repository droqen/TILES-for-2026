extends Node2D

@onready var player = $starman
# stupid lost starman
@onready var vessel : NavdiVessel = $"../NavdiVessel"

@onready var maze : Maze = $Maze

@warning_ignore("integer_division")
@onready var roomcellsize := vessel.vessel_room_size / 10
var roomcoord := Vector2i(5,-3)

func loadroom() -> void:
	maze.copy_from(vessel.get_maze(),Rect2i(roomcoord*roomcellsize,roomcellsize))

func _ready() -> void:
	loadroom.call_deferred()

func _physics_process(_delta: float) -> void:
	if is_instance_valid(player):
		var pcell := maze.local_to_map(player.position)
		if maze.get_cell_tid(pcell) == 99: player.queue_free()
		var traveldir := NavdiGenUtil.gen_oobdir(player.position,Rect2i(Vector2i(0,0),roomcellsize*10))
		if traveldir:
			print(traveldir)
			roomcoord += traveldir
			player.position.x -= move_toward(traveldir.x * 10 * roomcellsize.x, 0, 2)
			player.position.y -= move_toward(traveldir.y * 10 * roomcellsize.y, 0, 2)
			loadroom()
		
