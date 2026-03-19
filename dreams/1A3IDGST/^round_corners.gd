extends Node

const CCW : Array[Vector2i] = [
	Vector2i.RIGHT,
	Vector2i.UP,
	Vector2i.LEFT,
	Vector2i.DOWN,
]

@onready var maze : Maze = get_parent()
func _ready() -> void:
	var blanks := maze.get_used_cells_by_tids([0])
	var walls := maze.get_used_cells_by_tids([1])
	#var blanks_check = maze.get_used_cells_by_tids([0,40,99])
	#var walls_check = maze.get_used_cells_by_tids([1])
	for cell in blanks:
		var possibly_midcombo : bool = true
		var combo_start : int = 0
		var combo_length : int = 0
		for i in 8:
			if maze.get_cell_tid(cell + CCW[i%4]) == 1:
				if not possibly_midcombo:
					if not combo_length: combo_start = i
					combo_length += 1
			elif combo_length:
				break # we're done!
			else:
				possibly_midcombo = false
		if possibly_midcombo: combo_length = 4
		match combo_length:
			0,1: pass
			2: maze.set_cell_tid_transformed(cell, 30, combo_start%4)
			_: maze.set_cell_tid(cell, 9)
	for cell in walls:
		var possibly_midcombo : bool = true
		var combo_start : int = 0
		var combo_length : int = 0
		for i in 8:
			if not (maze.get_cell_tid(cell + CCW[i%4]) in [-1,1,2,3]):
				if not possibly_midcombo:
					if not combo_length: combo_start = i
					combo_length += 1
			elif combo_length:
				break # we're done!
			else:
				possibly_midcombo = false
		if possibly_midcombo: combo_length = 4
		match combo_length:
			0,1: pass
			2: maze.set_cell_tid_transformed(cell, 2, combo_start%4)
			3: maze.set_cell_tid_transformed(cell, 3, combo_start%4)
			4: maze.set_cell_tid_transformed(cell, 4)
			_: maze.set_cell_tid(cell, 9)
			
	queue_free()
	
