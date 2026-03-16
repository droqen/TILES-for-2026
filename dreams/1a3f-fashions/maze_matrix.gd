extends Node2D

@export var source_maze : Maze
@export var player : Node2D
@export var coords : Vector2i = Vector2i(5,5)

func _is_valid_maze_at_coords(at_coords:Vector2i) -> bool:
	var is_maze = get_node_or_null("%d,%d" % [at_coords.x,at_coords.y])
	return is_maze and is_maze is Maze

func _load_maze_at_coords() -> void:
	player.hide()
	$Error.show()
	for cell in source_maze.get_used_cells():
		source_maze.set_cell_tid(cell, 99)
	await get_tree().create_timer(0.5).timeout
	if is_inside_tree():
		var copy_maze = get_node_or_null("%d,%d" % [coords.x,coords.y])
		if copy_maze and copy_maze is Maze:
			var m2 := copy_maze as Maze
			for cell in m2.get_used_cells():
				source_maze.set_cell_tid(cell, m2.get_cell_tid(cell))
			player.show()
			$Error.hide()

func _ready() -> void:
	_load_maze_at_coords()

func _physics_process(_delta: float) -> void:
	if player.visible:
		var move_rooms : Vector2i
		var b : int = 2
		if player.position.x < 20-b: move_rooms.x -= 1
		if player.position.x > 80+b: move_rooms.x += 1
		if player.position.y < 20-b: move_rooms.y -= 1
		if player.position.y > 80+b: move_rooms.y += 1
		if move_rooms:
			if _is_valid_maze_at_coords(coords + move_rooms):
				player.position -= (60+b+b-1) * move_rooms as Vector2
				coords += move_rooms
				_load_maze_at_coords()
			else:
				player.hide() # no need to queue free.
