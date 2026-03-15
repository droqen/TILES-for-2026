extends Label

func gradually_delete() -> void:
	while visible_ratio > 0:
		if visible_characters > 0:
			visible_characters -= 1
		else: visible_ratio -= 0.001
		if !is_inside_tree(): break
		await get_tree().create_timer(randf() if randf() < 0.2 else 0.1).timeout
	
	if is_inside_tree():
		var maze = $"../Maze"
		if maze:
			for cell in maze.get_used_cells_by_tids([29]):
				maze.set_cell_tid(cell, 0)
