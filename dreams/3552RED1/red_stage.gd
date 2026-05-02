extends Node2D
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

func empty_parent(parent:Node) -> void:
	for child in parent.get_children():
		child.queue_free()
		parent.remove_child(child) #byee

func loadroom() -> void:
	var roomsizei : Vector2i = Vector2i(int(v.vessel_room_size.x/10),int(v.vessel_room_size.y/10))
	for p in [$pbullets,$foes,$roomxs]:empty_parent(p)
	maze.copy_from(v.get_maze(), Rect2i(roomcoord * roomsizei, roomsizei))
	initmaze() # spawns enemies and regenerates `astar`

const INIT_DONT_SPAWN_WITHIN_DISTSQ_OF_PLAYER : float = 20*20

func initmaze() -> void:
	astar = AStarGrid2D.new()
	var roomregion = Rect2i(Vector2i(0,0), Vector2i(v.vessel_room_size * 0.1))
	astar.region = NavdiGenUtil.shrink_rect2i(roomregion, -1)
	astar.update()
	astar.fill_solid_region(astar.region, false) # allowed to go around the outside
	astar.fill_solid_region(roomregion, true)
	#astar.region = NavdiGenUtil.shrink_rect2i(astar.region,-1)
	#astar.update()
	for cell in maze.get_used_cells_by_tids(EMPTY_TIDS):
		astar.set_point_solid(cell, false)
		# floor below?
		if maze.get_cell_tid(cell+Vector2i(0,1)) in [1,2]:
			var foepos = maze.map_to_local(cell)
			if foepos.distance_squared_to(get_player().position) > INIT_DONT_SPAWN_WITHIN_DISTSQ_OF_PLAYER:
				if randf() < 0.25:
					print(cell, " in ", roomregion.size)
					spawn_foe(cell)
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
		player.position -= room_bounds.size * Vector2(traveldir)
		roomcoord += traveldir
		loadroom()
	else:
		recalcmazeweights()
		keep_in_bounds(player)
		for foe in $foes.get_children(): keep_in_bounds(foe)
		for pbullet in $pbullets.get_children(): kill_out_of_bounds(pbullet)
