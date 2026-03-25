extends Node

@onready var noise = FastNoiseLite.new()
@onready var maze : Maze = get_parent()
@onready var player : Node2D = $"../../faller"
func _ready() -> void:
	ras()
	ras(0.8)
	ras(0.8)
	ras(0.8)
func ras(copybelowchance:float=0.0) -> void:
	var whitecells : Array[Vector2i] = []
	# maze_exit_cell_pos
	whitecells.append(Vector2i(3,5))
	if is_instance_valid(player):
		# player_cell_pos
		whitecells.append(maze.local_to_map(player.position))
	for y in range(-8,7):
		for x in range(-10,10):
			var c := Vector2i(x,y)
			if randf() < copybelowchance:
				if c in whitecells:
					maze.set_cell_tid(c, 7)
				elif y >= 7:
					maze.set_cell_tid(c, 2)
				else:
					maze.set_cell_tid(c,maze.get_cell_tid(Vector2i(x,y+1)))
			else:
				maze.set_cell_tid(c,randi_range(2,6))
func _physics_process(_delta: float) -> void:
	ras(0.8)
