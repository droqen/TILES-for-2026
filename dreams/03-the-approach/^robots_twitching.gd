extends Node

@onready var maze : Maze = get_parent()
@onready var sleeping_robot_cells : Array[Vector2i] = maze.get_used_cells_by_tids([11,12,41,42])
func _ready() -> void:
	for cell in sleeping_robot_cells:
		maze.set_cell_tid(cell, [41,42][randi()%2])
func _physics_process(_delta: float) -> void:
	for cell in sleeping_robot_cells:
		if randf() < 0.01:
			if maze.get_cell_tid(cell) in [11,12,41,42]:
				maze.set_cell_tid(cell, [11,12,41,42,41,42][randi()%6])
			else:
				# reassign
				sleeping_robot_cells = maze.get_used_cells_by_tids([11,12,41,42])
