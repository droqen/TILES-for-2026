extends Node2D

@onready var golem = $golem
@onready var maze : Maze = $Maze
@onready var vessel : NavdiVessel = $"../NavdiVessel"

var raininess := 0
var releasingrain := false
var requiredpause := 0

func _physics_process(_delta: float) -> void:
	if is_instance_valid(golem):
		var golemcell := maze.local_to_map(golem.position)
		if maze.get_cell_tid(golemcell) == 99:
			golem.disappear()
	else:
		maze.set_cell_tid(Vector2i(1,5), 0)
	
	print(raininess)
	
	raininess += 1
	if randf() * 10000 < raininess:
		releasingrain = true
	
	if releasingrain:
		if requiredpause > 0:
			requiredpause -= 1
		elif randf() < 0.1:
			requiredpause = 10
			var drop = vessel.spawn_exile_by_name("Droplet", $droplets)
			drop.position = Vector2(
				randf_range(5,95)
				,
				5
			)
			drop.splatted_at.connect(_spawn_splashes_at)
			raininess -= 60
			if raininess <= 0: releasingrain = false
func _spawn_splashes_at(pos:Vector2,_vel:Vector2) -> void:
	for dx in [-1,1]:
		for dy in [-1,1]:
			var splash = vessel.spawn_exile_by_name("Splash", $droplets)
			splash.velocity = Vector2(
				randf_range(0.2,0.3)*dx,
				randf_range(0.2,0.3)*dy)
			splash.position = pos + Vector2(-5 if dx<0 else 0, -5 if dy<0 else 0)
