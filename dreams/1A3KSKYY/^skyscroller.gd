extends Node
@onready var maze : Maze = get_parent()
@onready var buffer_maze : Maze = get_child(0) as Maze
@export var height : int = 19
#@export var scrollspeed : float = 0.1

func _ready() -> void:
	slide_left(190)

func slide_left(amount: float) -> void:
	maze.position.x -= amount
	var maze_leftx : int = 0
	var maze_rightx : int = 18
	while maze.position.x <= -10:
		maze.position.x += 10
		maze_leftx += 1
		grow_sky_rightcol(maze, maze_rightx, maze_rightx+1)
		maze_rightx += 1
	if maze_leftx > 0:
		buffer_maze.copy_from(maze, Rect2i(maze_leftx, 0, 20, height))
		maze.clear()
		maze.copy_from(buffer_maze, Rect2i(0, 0, 20, height))
		buffer_maze.clear()

func grow_sky_rightcol(sky : Maze, xold : int, xnew : int) -> void:
	for y in 19:
		var prevtid := sky.get_cell_tid(Vector2i(xold,y))
		var nexttid := prevtid
		match prevtid:
			0: if randf() < 0.02: nexttid = [2,2,2,2,3][randi()%5]
			1: nexttid = 0
			2: nexttid = [0,0,2,3][randi()%4]
			3: nexttid = [4,5,6][randi()%3]
			4: nexttid = [4,5,6,5,6][randi()%5]
			5: nexttid = [4,5,6][randi()%3]
			6: nexttid = [0,0,0,2,2,2,3][randi()%7]
		sky.set_cell_tid(Vector2i(xnew,y),nexttid)
func _physics_process(_delta: float) -> void:
	#slide_left(scrollspeed)
	slide_left(0.08 + maze.position.y * 0.004)
