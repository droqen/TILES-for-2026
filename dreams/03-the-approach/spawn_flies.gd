extends Node

const FLY_PS = preload("res://dreams/03-the-approach/fly_bot.tscn")
func _ready() -> void:
	var maze : Maze = $"../Maze"
	var sz = maze.get_used_rect().size
	for i in range(2):
		Dreamer.spawn(FLY_PS).setup_pos(Vector2(
			randf_range(0,sz.x),randf_range(0,sz.y)
		))
