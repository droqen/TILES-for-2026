extends Node

@onready var maze : Maze = get_parent()
const BOOKS : Array[int] = [3,4,5,6,]
func _ready() -> void:
	for cell in maze.get_used_cells_by_tids([1,14]):
		var above : int = 0
		for i in range(1,20):
			if maze.get_cell_tid(cell + Vector2i(0,-i)) == 0:
				above += 1
				continue
			else:
				break
		if above > 0:
			var climb : int = randi() % (above+1)
			for y in range(1,climb):
				maze.set_cell_tid(cell + Vector2i(0,-y), BOOKS[randi()%len(BOOKS)])
