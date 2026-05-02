extends Node2D

const FoeBase = preload("res://dreams/3552RED1/foebase.gd")

@onready var game = get_parent()
@onready var v : NavdiVessel = $"../v"
@onready var maze : Maze = $Maze
var astar : AStarGrid2D

@export var starting_roomcoord : Vector2i = Vector2i(0,0)
var roomcoord : Vector2i
var room_alert : int = 0
@onready var room_bounds : Rect2 = Rect2(Vector2(0,0), v.vessel_room_size)
@onready var game_bounds : Rect2i = $"../View".get_rect() as Rect2i

const EMPTY_TIDS : Array[int] = [0,8,9]
const SOLID_TIDS : Array[int] = [1,2]

var prev_entrances : Array[Vector2i] = []
var prev_foes : Array[FoeBase] = []
var prev_foe_delay : int

func empty_parent(parent:Node) -> void:
	for child in parent.get_children():
		if child is FoeBase and child.awake:
			#(child as FoeBase).calculate_distance_to_player(player_cell)
			prev_foes.append(child) # stash for later
			parent.remove_child(child)
		else:
			child.queue_free()
			parent.remove_child(child)

func loadroom(traveldir : Vector2i = Vector2i.ZERO) -> void:
	var roomsizei : Vector2i = Vector2i(int(v.vessel_room_size.x/10),int(v.vessel_room_size.y/10))
	for p in [$pbullets,$foes,$roomxs]:empty_parent(p)
	maze.copy_from(v.get_maze(), Rect2i(roomcoord * roomsizei, roomsizei))
	initmaze(traveldir) # spawns enemies and regenerates `astar`

const INIT_DONT_SPAWN_WITHIN_DISTSQ_OF_PLAYER : float = 20*20

func initmaze(traveldir : Vector2i = Vector2i.ZERO) -> void:
	
	var roomregion = Rect2i(Vector2i(0,0), Vector2i(v.vessel_room_size * 0.1))
	
	astar = AStarGrid2D.new()
	astar.region = NavdiGenUtil.shrink_rect2i(roomregion, -1)
	astar.update()
	astar.fill_solid_region(astar.region, false) # allowed to go around the outside
	astar.fill_solid_region(roomregion, true)
	
	prev_entrances.clear()
	prev_foe_delay = 0
	
	for cell in maze.get_used_cells_by_tids(EMPTY_TIDS):
		
		# empty cell : navigable
		astar.set_point_solid(cell, false)
		
		# empty cell with freedom to -traveldir : it's a prev entrance
		if ((cell.x == 0 and traveldir.x > 0)
		 or (cell.y == 0 and traveldir.y > 0)
		 or (cell.x == roomregion.size.x - 1 and traveldir.x < 0)
		 or (cell.y == roomregion.size.y - 1 and traveldir.y < 0)
		): prev_entrances.append(cell - traveldir)
		
		# floor below?
		if maze.get_cell_tid(cell+Vector2i(0,1)) in [1,2]:
			var foepos = maze.map_to_local(cell)
			if foepos.distance_squared_to(get_player().position) > INIT_DONT_SPAWN_WITHIN_DISTSQ_OF_PLAYER:
				if randf() < 0.25:
					spawn_foe(cell)
	
	#for en_cell in prev_entrances:
		#v.spawn_exile_by_name("prevEntranceMarker", $roomxs).position = maze.map_to_local(en_cell)
	
	astar.update()
	
const FLANK_MULTIPLIER : float = 4.0

func recalcmazeweights() -> void:
	if astar:
		astar.fill_weight_scale_region(astar.region, 1.0)
		for foe in $foes.get_children():
			var w = foe.get('blockade_weight')
			if w is float:
				astar.set_point_weight_scale(foe.cell,
					astar.get_point_weight_scale(foe.cell)
						+ w * FLANK_MULTIPLIER)
		astar.update()

func keep_in_bounds(n:Node2D) -> void:
	var oobdir = NavdiGenUtil.gen_oobdir(n.position, game_bounds)
	if oobdir.x < 0: n.position.x = game_bounds.position.x
	if oobdir.y < 0: n.position.y = game_bounds.position.y
	if oobdir.x > 0: n.position.x = game_bounds.end.x
	if oobdir.y > 0: n.position.y = game_bounds.end.y
func kill_out_of_bounds(n:Node2D) -> void:
	if NavdiGenUtil.gen_oobdir(n.position, game_bounds):
		n.queue_free()

func awaken_all_foes() -> void:
	for foe in $foes.get_children():
		foe.awaken()

func get_player():
	return $amoureux

func spawn_pbullets(player) -> void:
	for i in 2:
		(v
		.spawn_exile_by_name("amorbullet", $pbullets)
		.setup(self,player,i)
		)
		if i == 0: await get_tree().process_frame

func spawn_foe(cell:Vector2i) -> void:
	var _gearman = (v
	.spawn_exile_by_name("foegearman", $foes)
	.setup(self, maze, maze.map_to_local(cell))
	)

func _ready() -> void:
	hide()
	await get_tree().process_frame
	roomcoord = starting_roomcoord
	loadroom()
	show()

func _physics_process(_delta: float) -> void:
	var player = get_player()
	var traveldir = NavdiGenUtil.gen_oobdir(player.position, room_bounds, -1)
	if traveldir:
		if traveldir.x and traveldir.y: traveldir.x = 0
		player.position -= room_bounds.size * Vector2(traveldir)
		roomcoord += traveldir
		loadroom(traveldir)
	else:
		recalcmazeweights()
		keep_in_bounds(player)
		for foe in $foes.get_children(): keep_in_bounds(foe)
		for pbullet in $pbullets.get_children(): kill_out_of_bounds(pbullet)
	
	if prev_foes:
		if prev_foe_delay > 0:
			prev_foe_delay -= 1
		else:
			push_prev_foe_to_nearest(prev_foes.pop_front())
			prev_foe_delay = randi_range(10,30)

func push_prev_foe_to_nearest(prev_foe : FoeBase):
	if prev_entrances:
		var pcell = maze.local_to_map(get_player().position)
		prev_entrances.sort_custom(func(a,b):
			var adist = astar.get_point_path(a, pcell)
			var bdist = astar.get_point_path(b, pcell)
			return len(adist) < len(bdist)
		)
		prev_foe.setup(self, maze, maze.map_to_local(prev_entrances[0]))
		$foes.add_child(prev_foe)
		prev_foe.owner = owner if owner else self
