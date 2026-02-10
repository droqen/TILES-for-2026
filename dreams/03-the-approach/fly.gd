extends Node2D

@onready var maze : Maze = $"../Maze"
var target : Vector2
var targetcell : Vector2i
var velocity : Vector2
var myspeed : float
var lingertime : int
var whirl : float = 0.0
@onready var allcells = maze.get_used_cells()
func _ready() -> void:
	position = maze.map_to_local(random_cell())
	goto_random_target()
	velocity = (target-position).normalized()
func random_cell() -> Vector2i:
	return allcells[randi()%len(allcells)]
func goto_random_target() -> void:
	targetcell = random_cell()
	target = maze.map_to_local(targetcell) + Vector2(
		randf_range(-2.5,2.5),
		randf_range(-2.5,2.5)
	)
	lingertime = 10 + randi() % 20 * randi() % 20
	myspeed = randf_range(0.5,1.0)
func _physics_process(_delta: float) -> void:
	var to_target = target - position
	velocity = lerp(velocity,
		(to_target*0.1).limit_length(1),
		0.1)
	if to_target.length() < 0.1:
		if lingertime > 0:
			lingertime -= 1
		else:
			goto_random_target()
	position += velocity * myspeed
