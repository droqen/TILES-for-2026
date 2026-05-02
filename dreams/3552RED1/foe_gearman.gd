extends FoeBase

const FoeBase = preload("res://dreams/3552RED1/foebase.gd")

var awakening_timer : int = 0
var shifting_timer : int = 0

func setup(_stage,_maze:Maze,_pos:Vector2):
	super.setup(_stage,_maze,_pos)
	self.blockade_weight = 1.5
	self.hp = 1000
	$sprbody.setup([[20,21][randi()%2]],0)
	$sprgear.setup([[20,21,22][randi()%3]],0)
	return self

func _ready() -> void:
	if not awake: hide(); vy = 1; mover.try_move(self,solidcast,VERTICAL,vy)

func _physics_process(_delta: float) -> void:
	if dead:
		if bufs.has(DEADBUF): pass
		else: queue_free()
	elif awake:
		show()
		#if bufs.has(OUCHBUF): shifting_timer = 0; awakening_timer = 0
		if shifting_timer > 0:
			if bufs.has(OUCHBUF): $sprgear.setup([33,34],3)
			elif $sprgear.frame > 30: $sprgear.setup([20],0)
			shifting_timer -= 1
			if shifting_timer <= 0:
				vy = randf_range(-0.3,-0.4)
		elif awakening_timer > 0:
			if bufs.has(OUCHBUF): $sprgear.setup([33,34],3)
			awakening_timer -= 1
			$sprgear.setup_trywaitformatch([20,21,22], 20)
			$sprbody.setup_trywaitformatch([20,21], 31)
			if awakening_timer == 0:
				stage.awaken_all_foes()
		else:
			awake = true
			if bufs.has(OUCHBUF):
				$sprgear.setup([33,34],3)
			else:
				$sprgear.setup([30,31,32],8)
			$sprbody.setup([30,31],13)
			if bufs.has(OUCHBUF):
				targetplayer = null # lost target
			elif not is_instance_valid(targetplayer):
				targetplayer = stage.get_player()
			else:
				var astar := stage.astar as AStarGrid2D
				cell = maze.local_to_map(position)
				var targetcell := maze.local_to_map(targetplayer.position)
				var path := astar.get_point_path(
					cell,
					targetcell,
					true, # partial paths allowed.
				)
				if len(path)>1:
					var gotocell := path[1]
					var gotopos := maze.map_to_local(gotocell)
					var v2 = gotopos-position
					var tvx : float = sign(v2.x) * 0.5
					var tvy : float = sign(v2.y) * 0.5
					if tvy > 0: tvy *= 2
					vx = move_toward(vx, tvx, 0.05)
					vy = move_toward(vy, tvy, 0.05)
	
	if not awake or not is_instance_valid(targetplayer) or awakening_timer > 0:
		vy = move_toward(vy, 1, 0.04)
		if vy >= 0 and mover.cast_fraction(self,solidcast,VERTICAL,1)<1:
			vx = move_toward(vx, 0, 0.1) # slowdown
	
	if!mover.try_slip_move(self,solidcast,HORIZONTAL,vx):
		vx = 0
	if!mover.try_slip_move(self,solidcast,VERTICAL,vy):
		vy = 0
		if not visible: show()

func try_hitby(_hitter) -> bool:
	if super.try_hitby(_hitter):
		vx = vx * 0.9 + 0.1 * _hitter.vx
		return true
	return false # else

func awaken() -> void:
	if not awake:
		awake = true
		if bufs.has(OUCHBUF):
			shifting_timer = 1
			awakening_timer = 10
		else:
			shifting_timer = randi_range(10,40)
			awakening_timer = randi_range(30,50)
			if randf () < 0.1: shifting_timer += randi_range(10,200)
			if randf () < 0.02: awakening_timer += randi_range(10,200)
		#stage.awaken_all_foes()
