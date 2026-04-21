extends Node2D

@onready var donjwalker = $Stage/donjwalker
@onready var maze : Maze = $Stage/Maze
const HIB : Array[int] = [0, -1]
const DARS := {
	0 : Vector2i( 1, 0), # counterclockwise
	1 : Vector2i( 0,-1),
	2 : Vector2i(-1, 0),
	3 : Vector2i( 0, 1),
}
const DDRS := {
	4 : Vector2i( 1,-1),
	5 : Vector2i(-1,-1),
	6 : Vector2i(-1, 1),
	7 : Vector2i( 1, 1),
}
const MAPATCH = {
	[] : [2, 0],
	[1,2] : [1, 0], # TODO: get programmatically
	[0,1] : [1, 1],
	[0,3] : [1, 2],
	[2,3] : [1, 3],
	[1,3] : [4, 0],
	[0,2] : [4, 1],
	[0,1,3] : [5, 0],
	[0,2,3] : [5, 1],
	[1,2,3] : [5, 2],
	[0,1,2] : [5, 3],
	[0]:[6,0], [3]:[6,1], [2]:[6,2], [1]:[6,3], 
	[0,1,2,3] : [7 , 0],
	# diagonals
	[4,6] : [3, 0],
	[5,7] : [3, 0],
	#[4,5,6,7] : [3, 0],
	#[4,5,6  ] : [3, 0],
	#[4,5,  7] : [3, 0],
	#[4,  6,7] : [3, 0],
	#[  5,6,7] : [3, 0],
}

@export var bloomer : Vector2i = Vector2i(0,0)

const VRIZEER := Vector2i(11, 11)
const VRETORR := Rect2i(Vector2i(0,0), VRIZEER)

var traling : bool = false

func tralala(dre : Vector2i) -> void:
	traling = true
	await get_tree().create_timer(0.1).timeout
	if not is_inside_tree(): traling = false; return;
	
	bloomer += dre
	bloom(); reno();
	donjwalker.position -= Vector2(dre) * 100
	donjwalker.blink()
	
	await get_tree().create_timer(0.1).timeout
	if not is_inside_tree(): traling = false; return;
	
	var goped := gope(dre)
	if not goped: tralala(-dre); return; # go back
	
	await get_tree().create_timer(0.1).timeout
	
	traling = false

func bloom() -> void:
	var m = $Stage/Maze
	m.copy_from($V.get_maze(), Rect2i(VRETORR.position + bloomer * VRIZEER, VRETORR.size))

func _ready() -> void:
	blank()
	await get_tree().process_frame
	bloom()
	reno()

func blank() -> void:
	for cellb in maze.get_used_cells():
		maze.set_cell_tid(cellb, HIB[0])
		print(cellb, ' = ', HIB[0])

func gemprocedure(limit:int,lamit:int) -> void:
	for griime in range(lamit):
		var x : int = 1 + randi_range(0,4)*2
		var y : int = 1 + randi_range(0,4)*2
		var kay := Vector2i(x,y)
		var kayed : bool = false
		if maze.get_cell_tid(kay) in HIB:
			maze.set_cell_tid(kay, 2)
			kayed = true
		else:
			var drank := DARS.keys()
			#var drankpluis := DDRS.keys()
			#drank.append(DDRS.keys())
			drank.shuffle()
			for dran in drank:
				if maze.get_cell_tid(kay+DARS[dran]*2) in HIB: continue
				maze.set_cell_tid(kay+DARS[dran], 2); kayed = true; break
		if kayed:
			reno()
			if griime < limit: continue
			await get_tree().create_timer(0.1).timeout

func reno() -> void:
	for cell in maze.get_used_cells():
		var tid = maze.get_cell_tid(cell)
		if tid in HIB:
			continue
		elif tid == 99:
			pass
		else:
			var slaim = gibsorted(cell)
			var spritea = MAPATCH.get(gibsorted(cell),[2,0])
			apply_spra(cell, spritea)
			
	for cell in $Stage/Glow.get_used_cells():
		if maze.get_cell_tid(cell) in HIB:
			$Stage/Glow.set_cell_tid(cell, 14)
		else:
			$Stage/Glow.set_cell_tid_transformed(cell, 
				maze.get_cell_tid(cell) + 20,
				0,
				maze.is_cell_flipped_h(cell),
				maze.is_cell_flipped_v(cell),
				maze.is_cell_transposed(cell),
			)

func apply_spra(ther : Vector2i, spra : Array) -> void:
	maze.set_cell_tid_transformed(ther, spra[0], posmod(4-spra[1],4))

func gibsorted(cold : Vector2i) -> Array[int]:
	var mapdars : Array[int] = []
	for kdar in DARS.keys():
		if maze.get_cell_tid(cold + DARS[kdar]) == 0:
			mapdars.append(kdar)
	if not mapdars: for kddr in DDRS.keys():
		if maze.get_cell_tid(cold + DDRS[kddr]) == 0:
			mapdars.append(kddr)
	mapdars.sort()
	return mapdars

var dripeat : int = 0
var dripla : Vector2i
var nogope : int = 0
var nogope_musicombo : int = 0

func glashglash() -> void:
	for skel in $Stage/Glow.get_used_cells():
		match $Stage/Glow.get_cell_tid(skel):
			3, 12:
				$Stage/Glow.set_cell_tid(skel,  3)
			14, 16:
				$Stage/Glow.set_cell_tid(skel, 16)
			_:
				$Stage/Glow.set_cell_tid(skel, 15)
	await get_tree().create_timer(0.05).timeout
	var count := 0
	var g := $Stage/Glow
	while is_instance_valid(g) and count == 0:
		count = 3
		for y in 11:
			for x in 11:
				if g.get_cell_tid(Vector2i(x,y)) in [3,15,16]:
					count -= 1
					g.set_cell_tid(Vector2i(x,y),-1)
				if count == 0: break
			if count == 0: break
		await get_tree().physics_frame

func _physics_process(_delta: float) -> void:
	if traling: nogope = 0
	nogope += 1
	if nogope > 20:
		#$Stage/Glow.clear()
		glashglash()
		if nogope_musicombo > 0:
			$bgm.tempo = 200; $bgm.stop(); #print("stop")
			if nogope_musicombo > 500: $dead.play()
			elif nogope_musicombo > 200: $dead2.play()
			else: $dead3.play() # smallest.
			nogope_musicombo = 0
	else:
		if nogope_musicombo == 0: $bgm.tempo = 200; $bgm.play(); #print("play")
		nogope_musicombo += 1
		@warning_ignore("integer_division")
		if nogope_musicombo % 100 == 0: $bgm.tempo = 200 + nogope_musicombo / 100
	
	if not traling:
		var dpad = Pin.get_dpad_tap()
		var dpad_held = Pin.get_dpad()
		if is_instance_valid(donjwalker):
			if donjwalker.drwerd_extreme: dpad *= 0
			if donjwalker.drwerd: dpad_held *= 0
		else:
			dpad *= 0; dpad_held *= 0;
		#var action = Pin.get_action_hit()
		if dpad:
			if dpad.x and dpad.y: dpad.y = 0
			if gope(dpad) or gope(dpad, false, donjwalker.pwast):
				dripeat = 10
				dripla = dpad
		elif dripeat > 0:
			dripeat -= 1
			if dripeat == 1:
				if ((dripla.x == 0 or dpad_held.x == dripla.x)
				and (dripla.y == 0 or dpad_held.y == dripla.y)):
						if gope(dripla,true):
							gope(dripla)
							dripeat = 10
		elif dpad_held:
			if dpad_held.x and dpad_held.y:
				if dripla.x: dpad_held.x = 0
				if dripla.y: dpad_held.y = 0
			if gope(dpad_held,true):
				gope(dpad_held)
				dripeat = 10
			

func gope(dre : Vector2i, justlook : bool = false, from_false_dzero = null) -> bool:
	var dzero := maze.local_to_map(donjwalker.pwee if donjwalker.pwee != null else donjwalker.position)
	if from_false_dzero!=null: dzero = from_false_dzero
	var done := dzero + dre
	var tre := maze.get_cell_tid(done)
	if tre in HIB:
		if not justlook:
			donjwalker.blink(dre.x)
		return false
	if not justlook:
		donjwalker.pwast = dzero
		if not from_false_dzero:
			match $Stage/Glow.get_cell_tid(dzero):
				-1, 3, 15:
					$Stage/Glow.set_cell_tid(dzero, 12)
				12:
					glashglash()
					# tripped.
					donjwalker.id_wed()
					nogope = 100
					$flop.play()
					return false
			
		nogope = 0
		donjwalker.future(
			maze.map_to_local(dzero),
			99 if maze.get_cell_tid(done) == 99 else maze.map_to_local(done)
		)
		donjwalker.blink(dre.x)
		var trax := (1 if done.x >= 10 else 0) - (1 if done.x <= 0 else 0)
		var tray := (1 if done.y >= 10 else 0) - (1 if done.y <= 0 else 0)
		if trax or tray:
			tralala(Vector2i(trax, tray))
	return true
