extends Node2D

@onready var maze : Maze = $Maze
@onready var walkers : Node = $Walkers
@onready var vessel : NavdiVessel = $"../NavdiVessel"
@onready var eyephelia = $Eyephelia
var astar := AStarGrid2D.new()
var winddir := Vector2(10,0)

func _ready() -> void:
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	astar.region = maze.get_used_rect()
	astar.offset = Vector2(5,5)
	astar.cell_size = maze.tile_set.tile_size
	astar.update()
	astar.fill_solid_region(maze.get_used_rect(), false)
	astar.fill_solid_region(Rect2i(0,17,20,1), true) # bottom row
	astar.set_point_solid(Vector2i(9,17), false) # fire (left)
	astar.set_point_solid(Vector2i(10,17), false) # fire (right)
	astar.fill_weight_scale_region(maze.get_used_rect(), 1.0)
	for dx in astar.region.size.x:
		for dy in astar.region.size.y:
			var cell := Vector2i(dx,dy) + astar.region.position
			match maze.get_cell_tid(cell):
				1,2,3,4,5,6,7,8,9:
					astar.set_point_solid(cell, true)
	astar.update()
	#loadsmokes.call_deferred()
	#maze.changed.connect(func(): astar.update())
	$Eyephelia.dug.connect(func(cell): astar.set_point_solid(cell,false))
#func loadsmokes() -> void:
	#for x in 20:
		#for _i in 3:
			#(vessel
			#.spawn_exile_by_name("Smoke", walkers)
			#.setup(Vector2(5+x*10,175))
			#)
var createsmoke : int = 0
var createsmokex : int = 9+randi()%2
func _physics_process(_delta: float) -> void:
	if createsmoke > 0:
		createsmoke -= 1
	else:
		(vessel
		.spawn_exile_by_name("Smoke", walkers)
		.setup(Vector2(5+createsmokex*10,175))
		)
		createsmokex = 9 if createsmokex == 10 else 10
		createsmoke = randi_range(5,10)
	var ws : Dictionary = {}
	for x in 20:
		for y in 18:
			var c := Vector2i(x,y)
			var weight := astar.get_point_weight_scale(c)
			ws[c] = max(weight * 0.9, 1.0)
	for walker in walkers.get_children():
		# smoke clogs
		var a := maze.local_to_map(walker.position)
		if ws.has(a):
			ws[a] += 0.5
	astar.fill_weight_scale_region(maze.get_used_rect(), 1.0)
	for c in ws.keys():
		var w : float = ws[c]
		if w > 1.0:
			astar.set_point_weight_scale(c, w)
	for walker in walkers.get_children():
		var a := maze.local_to_map(walker.position)
		var b := maze.local_to_map(walker.target)
		var path = astar.get_point_path(a,b)
		var b2 := maze.local_to_map(walker.target + winddir)
		if b2 != b:
			var path2 = astar.get_point_path(a,b)
			if path2 and len(path2) < len(path):
				walker.target += winddir
				path = path2
		else:
			walker.target += winddir
		walker.path_point = path
