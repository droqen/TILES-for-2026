extends Node2D

@onready var maze : Maze = $Maze
@onready var v : NavdiVessel = $V
const ROOMSIZE := Vector2i(24, 19)

var roomx : int = 0
const ROOMY : int = 0

func _ready() -> void:
	hide()
	await get_tree().process_frame
	loadroom()
	show()

func _physics_process(_delta: float) -> void:
	var amani : Node2D = get_node_or_null("amani")
	if amani:
		amani.position.y = fposmod(amani.position.y+5, 195)-5 # no behaviour
		if amani.position.x > 240:
			amani.position.x -= 240
			travel(1)
		if amani.position.x < 0:
			amani.position.x += 240
			travel(-1)
		
		if amani.position.y > 173:
			var pcell : Vector2i = maze.local_to_map(amani.position)
			var tid : int = maze.get_cell_tid(pcell)
			if tid >= 98:
				amani.queue_free()
				destroy_world()
	elif randi() % 10 == 0: # extending the period gradually.
		$"Maze/^tilecycler".period += 1
		$"Maze/^tilecycler2".period += 1

func travel(dx:int) -> void:
	roomx += dx
	loadroom()

func loadroom() -> void:
	maze.copy_from(v.exiled_maze, Rect2i(Vector2i(roomx,ROOMY) * ROOMSIZE, ROOMSIZE))
	v.spawn_exiles_by_roomcoords(Vector2i(roomx,ROOMY), $E)

func destroy_world() -> void:
	#for cell in maze.get_used_cells_by_tids([96,97]): #hide the lines
		#maze.set_cell_tid(cell, 0)
	for cell in maze.get_used_cells_by_tids([98,99]): #hide the portal.
		maze.set_cell_tid(cell, 0)
		#$Label.hide()
	$bgm.stop()
	$bye.play()
