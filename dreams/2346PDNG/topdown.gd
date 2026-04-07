extends Node2D

@onready var maze : Maze = $Maze
@onready var player : Node2D = $Player
var playerdir := 0 # 0 is up, then clockwise i guess
const DIRS : Array[Vector2i] = [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT, ]

#func _physics_process(_delta: float) -> void:
	#var dxy := Pin.get_dpad_tap()
	#if dxy.x:
		#playerdir = posmod(playerdir + dxy.x, 4)
func control_player_turn(turndir:int) -> void:
	playerdir = posmod(playerdir + turndir, 4)
	$Player.rotation = playerdir * PI * 0.5
func control_player_try_step(ydir:int) -> bool:
	var stepdir := DIRS[playerdir] * ydir
	var pcell := maze.local_to_map(player.position)
	if maze.get_cell_tid(pcell+stepdir) == 8:
		player.position = maze.map_to_local(pcell+stepdir)
		return true
	else:
		return false # no move

const tiles34 = [
	# 0f
				  Vector2i(1,0),
	# 1f
	Vector2i(0,1),Vector2i(1,1),
	# 2f
	Vector2i(0,2),Vector2i(1,2),Vector2i(2,2),
	# 3f
	Vector2i(0,3),Vector2i(1,3),Vector2i(2,3),Vector2i(3,3),
]

func get34solidsatplayer() -> Array[Vector2i]:
	return get34solids(
		maze.local_to_map(player.position),
		DIRS[playerdir],
	)
func get34solids(pos:Vector2i,facingdir:Vector2i) -> Array[Vector2i]:
	var rightdir:Vector2i = Vector2i(-facingdir.y, facingdir.x)
	var solids34 : Array[Vector2i]
	for t34 in tiles34:
		if t34.x == 0:
			if maze.get_cell_tid(pos + facingdir * t34.y) == 9:
				solids34.append(t34)
		else:
			if maze.get_cell_tid(pos + facingdir * t34.y + rightdir * t34.x) == 9:
				solids34.append(t34)
			if maze.get_cell_tid(pos + facingdir * t34.y - rightdir * t34.x) == 9:
				t34.x *= -1
				solids34.append(t34)
	return solids34
