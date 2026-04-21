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
	[4,6] : [3],
	[5,7] : [3],
}

func _ready() -> void:
	blank()
	gemprocedure(20,100)

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
		else:
			var slaim = gibsorted(cell)
			var spritea = MAPATCH.get(gibsorted(cell),[2,0])
			apply_spra(cell, spritea)

func apply_spra(ther : Vector2i, spra : Array) -> void:
	maze.set_cell_tid_transformed(ther, spra[0], posmod(4-spra[1],4))

func gibsorted(cold : Vector2i) -> Array[int]:
	var mapdars : Array[int] = []
	for kdar in DARS.keys():
		if maze.get_cell_tid(cold + DARS[kdar]) == 0:
			mapdars.append(kdar)
	mapdars.sort()
	return mapdars

func _physics_process(_delta: float) -> void:
	var dpad = Pin.get_dpad_tap()
	var action = Pin.get_action_hit()
	if dpad: gope(dpad)

func gope(dre : Vector2i, justlook : bool = false) -> bool:
	var dzero := maze.local_to_map(donjwalker.position)
	var done := dzero + dre
	var tre := maze.get_cell_tid(done)
	if tre in HIB:
		return false
	if not justlook:
		donjwalker.position = maze.map_to_local(done)
		donjwalker.blink(dre.x)
	return true
