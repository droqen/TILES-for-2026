extends Node

@onready var maze : Maze = get_parent()

var juice := 50

var waitttt : float = 0.5
var morewaittttt : float = 0.5
var mwphase : int = 0

#var goal_density := 0.5

func _physics_process(delta: float) -> void:
	if waitttt > 0: waitttt -= delta; return;
	
	var repeats := 0
	if morewaittttt > 0:
		morewaittttt -= delta;
		if mwphase % 10 == 0: repeats = 1+ceil(mwphase/10.0);
		mwphase += 1
	else: for i in 10:
		if randi() % juice > i * 10 : repeats += 1
		else : break
	for _i in repeats:
		juice -= 1
		var cells := maze.get_used_cells_by_tids([0,4])
		if len(cells):
			var targetcell = cells[randi()%len(cells)]
			var delay : float = randf_range(0.05,0.11)
			match maze.get_cell_tid(targetcell):
				#0: if randf() < goal_density: fade(targetcell,[1,2,3,4],delay); juice -= 1;
				#4: if randf() > goal_density: fade(targetcell,[3,2,1,0],delay); juice -= 1;
				0: fade(targetcell,[1,2,3,4],delay); #juice -= 1;
				4: fade(targetcell,[3,2,1,0],delay); #juice -= 1;
	if randi() % 100 == 0:
		juice = maxi(juice, randi() % 100)
		#goal_density = lerp(goal_density, randf_range(0.1, 0.9), randf())
func fade(cell : Vector2i, frames : Array[int], rate : float) -> void:
	for frame in frames:
		maze.set_cell_tid(cell, frame)
		await get_tree().create_timer(rate).timeout
		if not is_instance_valid(maze): break
