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
func random_robot_cell() -> Vector2:
	var robotcells = maze.get_used_cells_by_tids([11,12,41,42])
	if robotcells:
		return robotcells[randi()%len(robotcells)]
	else:
		return random_cell()
const CRAWLER_BOT_PS = preload("res://dreams/03-the-approach/crawler_awakebot.tscn")
func goto_random_target() -> void:
	var currentcell = targetcell
	var currcelltid = maze.get_cell_tid(currentcell)
	lingertime = randi() % 15 * randi() % 15
	targetcell = random_cell()
	match currcelltid:
		11,12,41,42:
			Dreamer.spawn(CRAWLER_BOT_PS).setup_varvals(
				["frm_ground", currcelltid]
			).setup_pos(maze.map_to_local(currentcell))
			maze.set_cell_tid(currentcell, 0)
			lingertime += randi_range(100,200)
		_:
			if randf() < 0.25:
				targetcell = random_robot_cell()
	
	target = maze.map_to_local(targetcell) + Vector2(
		randf_range(-2.5,2.5),
		randf_range(-2.5,2.5)
	)
	myspeed = randf_range(0.25,0.40)
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
