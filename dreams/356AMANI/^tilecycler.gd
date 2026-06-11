extends Node

@export var frameorder : Array[int] = [0, 1, 2]
@export var scramble : bool = true
@export var period : int = 100
var _p : int = 0
@onready var maze : Maze = get_parent() as Maze
@onready var fcount : int = len(frameorder)

func _ready() -> void:
	if scramble:
		for cell in maze.get_used_cells_by_tids(frameorder):
			maze.set_cell_tid(cell, frameorder[randi()%fcount])
	_p = period
func _physics_process(_delta: float) -> void:
	if _p:
		_p -= 1
	else:
		_p = period
		for cell in maze.get_used_cells_by_tids(frameorder):
			var tid := maze.get_cell_tid(cell)
			var fi := frameorder.find(tid)
			if fi >= 0:
				if scramble:
					maze.set_cell_tid(cell, frameorder[(fi+1+randi()%(fcount-1))%fcount])
				else:
					maze.set_cell_tid(cell, frameorder[(fi+1)%fcount])
			else:
				push_warning("(tilecycler) unknown tid %d; how'd that get in there, anyway?" % tid)
