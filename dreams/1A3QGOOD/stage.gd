extends Node2D
@onready var maze : Maze = $Maze
@onready var player = $the_player_is_fine
const WATER := [61,51,41,40,50,60] # dark to light
var phase := 0
func _physics_process(_delta: float) -> void:
	
	if is_instance_valid(player):
		if maze.get_cell_tid(maze.local_to_map(player.position)) == 99:
			player.queue_free()
	
	for x in [9,10]:
		for y in range(18,-1-1,-1):
			if randf() < remap(y,-1,18,0.4,0.6):
				if randf() < 0.8:
					if y == -1:
						maze.set_cell_tid(Vector2i(x,y),
							WATER[0])
					else:
						maze.set_cell_tid(Vector2i(x,y),
						maze.get_cell_tid(Vector2i(x,y-1)))
				else:
					maze.set_cell_tid(Vector2i(x,y),
						WATER[randi()%len(WATER)])
	for x in [-1, 0, 1, 2, 3, 4, 5, 6, 7, 8,
			  20,19,18,17,16,15,14,13,12,11]:
		for y in [17,18,]:
			if randf() < remap(abs(x-9.5),0.5,10.5,0.5,0.1):
				if x < 9:
					maze.set_cell_tid(Vector2i(x,y),
					maze.get_cell_tid(Vector2i(x+1,y)))
				if x > 10:
					maze.set_cell_tid(Vector2i(x,y),
					maze.get_cell_tid(Vector2i(x-1,y)))
