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
	reset_world(true)
	eyephelia.dug.connect(func(cell): astar.set_point_solid(cell,false))
func reset_world(skipblink:bool=false) -> void:
	eyephelia.position.y = -5
	for x in range(-1,20+1):
		for y in 18+1:
			maze.set_cell_tid(Vector2i(x,y),2)
	if skipblink:
		eyephelia.position.y = 15
	else:
		await get_tree().create_timer(0.2).timeout
	if not is_inside_tree(): return # it's ovah
	var c : Vector2i
	var possiblefiretiles = []
	maze.set_cell_tid(Vector2i(-1 if eyephelia.position.x > randf_range(50,150) else 20, 1), 99)
	for x in 20:
		c.x = x
		for y in [0,1,17]:
			c.y = y
			maze.set_cell_tid(c, 0)
		for y in range(2, 16+1, 2):
			c.y = y
			maze.set_cell_tid(c, 4+randi()%3)
			if randf() < 0.07 + y * 0.002:
				maze.set_cell_tid(c, 0)
				if y < 16:
					possiblefiretiles.append(c + Vector2i.DOWN)
		c.y = 18
		maze.set_cell_tid(c, 2)
	for x in 20:
		c.x = x
		for y in range(3, 15+1, 2):
			c.y = y
			if (maze.get_cell_tid(c+Vector2i.UP)!=0
			and maze.get_cell_tid(c+Vector2i.DOWN)!=0
			and randf() < 0.05 + y * 0.002):
				maze.set_cell_tid(c, 3)
				if maze.get_cell_tid(c+Vector2i(0,-2)) == 3:
					maze.set_cell_tid(c+Vector2i(0,-1), 3)
			else:
				maze.set_cell_tid(c, 0)
	
	if len(possiblefiretiles) < 3:
		possiblefiretiles.append(Vector2i(randi_range(0,5),17))
		possiblefiretiles.append(Vector2i(randi_range(6,10),17))
		possiblefiretiles.append(Vector2i(randi_range(11,14),17))
		possiblefiretiles.append(Vector2i(randi_range(15,19),17))
	possiblefiretiles.shuffle()
	possiblefiretiles.sort_custom(func(a,b):return a.y>b.y)
	for i in range(3):
		maze.set_cell_tid(possiblefiretiles[i], 18)
		maze.set_cell_tid(possiblefiretiles[i]+Vector2i.UP, 0)
		maze.set_cell_tid(possiblefiretiles[i]+Vector2i.DOWN, 4+randi()%3)
	
	astar.fill_solid_region(maze.get_used_rect(), false)
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
	
	maze.set_cell_tid(Vector2i( 0, 0), 32)
	maze.set_cell_tid(Vector2i(19, 0), 33)
	maze.set_cell_tid(Vector2i( 0,17), 34)
	maze.set_cell_tid(Vector2i(19,17), 35)
#func loadsmokes() -> void:
	#for x in 20:
		#for _i in 3:
			#(vessel
			#.spawn_exile_by_name("Smoke", walkers)
			#.setup(Vector2(5+x*10,175))
			#)
var createsmokex : int = 0
func _physics_process(_delta: float) -> void:
	if is_instance_valid(eyephelia) and eyephelia.position.y > 184:
		reset_world()

	var ws : Dictionary = {}
	var smokedensities : Dictionary[Vector2i,int]
	var all_my_walkers = walkers.get_children()
	for x in 20:
		for y in 18:
			var c := Vector2i(x,y)
			var weight := astar.get_point_weight_scale(c)
			ws[c] = max(weight * 0.9, 1.0)
	for walker in all_my_walkers:
		# smoke clogs
		var a := maze.local_to_map(walker.position)
		if ws.has(a):
			ws[a] += 0.5
		smokedensities.set(a, smokedensities.get(a, 0) + 1)
	astar.fill_weight_scale_region(maze.get_used_rect(), 1.0)
	for c in ws.keys():
		var w : float = ws[c]
		if w > 1.0:
			astar.set_point_weight_scale(c, w)
	for walker in all_my_walkers:
		var a := maze.local_to_map(walker.position)
		var b := maze.local_to_map(walker.target)
		var path = astar.get_point_path(a,b)
		walker.cell_from_above = a
		walker.cell_center_from_above = maze.map_to_local(a)
		walker.smokedensities_from_above = smokedensities
		if path:
			var b2 := maze.local_to_map(walker.target + winddir)
			if b2 != b:
				var path2 = astar.get_point_path(a,b)
				if path2 and len(path2) < len(path):
					walker.target += winddir
					path = path2
			else:
				walker.target += winddir
		walker.path_point = path
		
	createsmokex = (createsmokex+1)%20
	for y in 18:
		var firecell = Vector2i(createsmokex,y)
		match maze.get_cell_tid(firecell):
			18:
				if smokedensities.get(firecell,0)==0:
					maze.set_cell_tid_transformed(firecell, 18, 0, !maze.is_cell_flipped_h(firecell))
					(vessel
					.spawn_exile_by_name("Smoke", walkers)
					.setup(maze.map_to_local(firecell) + Vector2.UP * randf() * 5)
					)
