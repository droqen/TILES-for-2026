extends Node

@onready var maze : Maze = get_parent()

var juice := 50

func _physics_process(_delta: float) -> void:
	var repeats := 0
	for i in 10:
		if randi() % juice > i*10 : repeats += 1
		else : break
	for _i in repeats:
		juice -= 1
		var cells := maze.get_used_cells_by_tids([0,4])
		if len(cells):
			var targetcell = cells[randi()%len(cells)]
			var delay : float = randf_range(0.05,0.11)
			match maze.get_cell_tid(targetcell):
				0: fade(targetcell,[1,2,3,4],delay)
				4: fade(targetcell,[3,2,1,0],delay)
	if randi() % 100 == 0:
		juice = maxi(juice, randi() % 100)
func fade(cell : Vector2i, frames : Array[int], rate : float) -> void:
	for frame in frames:
		maze.set_cell_tid(cell, frame)
		await get_tree().create_timer(rate).timeout
		if not is_instance_valid(maze): break
