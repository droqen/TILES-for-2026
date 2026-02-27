extends Node2D

@export var player : Node2D
@onready var ents : Node2D = $entities
@onready var maze : Maze = $Maze
@onready var vew : NavdiViewRect = $View

var vewcell : Vector2i
var vewtarget : Vector2
var vewmoverate : float = 1.0
var playertarget : Vector2
var playermoverate : float

func _physics_process(_delta: float) -> void:
	var playercell = maze.local_to_map(player.position)
	@warning_ignore("integer_division")
	var playervewcell = Vector2i(floor((playercell.x+5)/10.0),floor((playercell.y+5)/10.0))
	if vewcell != playervewcell:
		vewcell = playervewcell
		vewtarget = Vector2(vewcell * 100)
		playertarget = player.position
		if vewtarget.x != vew.position.x:
			playertarget.x = maze.map_to_local(playercell).x
		if vewtarget.y != vew.position.y:
			playertarget.y = maze.map_to_local(playercell).y
		playermoverate = playertarget.distance_to(player.position) / vewtarget.distance_to(vew.position)
	if vew.position != vewtarget:
		ents.process_mode = Node.PROCESS_MODE_DISABLED
		vew.move_to(vew.position + (vewtarget-vew.position).limit_length(vewmoverate))
		player.position += (playertarget-player.position).limit_length(playermoverate)
		if vew.position == vewtarget:
			ents.process_mode = Node.PROCESS_MODE_INHERIT
			player.position = playertarget

#func _draw() -> void:
	#pass
	##for x in range(-10,10+1):
		##for y in range(-10,10+1):
			##draw_line(Vector2(x*2+x,y*2)*50, Vector2(x*2-x,y*2)*50, Color.RED)
			##draw_line(Vector2(x*2,y*2+y)*50, Vector2(x*2,y*2-y)*50, Color.RED)
			##print(x,y)
