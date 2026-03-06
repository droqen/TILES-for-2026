extends Node

var maze : Maze :
	get : return $".."

func _physics_process(_delta: float) -> void:
	if randf()<0.02:
		var x : int = randi()%19
		var y : int = randi()%15
		maze.set_cell_tid(Vector2i(x,y),randi()%200)
		await get_tree().create_timer(randf_range(.02,.8)).timeout
		maze.set_cell_tid(Vector2i(x,y),-1)
