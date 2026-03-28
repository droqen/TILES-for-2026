extends Node2D

@onready var maze : Maze = $Maze
@onready var player = $moongazer
@onready var knives = $Knives
@onready var vessel : NavdiVessel = $"../NavdiVessel"

var knife_right_spawn_timer := randi() % 100
var knife_down_right_spawn_timer := randi() % 200

func _physics_process(_delta: float) -> void:
	if is_instance_valid(player) and player.sitting and player.spr.frame == 50:
		maze.hide()
		knives.show()
	else:
		maze.show()
		knives.hide()
	
	if knife_right_spawn_timer > 0:
		knife_right_spawn_timer -= 1
	else:
		# these come very regularly.
		knife_right_spawn_timer = 200
		var _knife = vessel.spawn_exile_by_name("KnifeRight", $Knives)
		#knife.position = Vector2(-6,105)
	
	if knife_down_right_spawn_timer > 0:
		knife_down_right_spawn_timer -= 1
	else:
		# these come semiregularly, but in 'showers'
		knife_down_right_spawn_timer = [1,1,1,267][randi()%4]
		var knife = vessel.spawn_exile_by_name("KnifeDownRight", $Knives)
		var targetx = randi_range(40,215)
		var targety = 105
		knife.position = Vector2(targetx,targety) - Vector2.ONE * (min(targetx,targety)+6)
