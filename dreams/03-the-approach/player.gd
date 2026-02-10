extends Node2D

@onready var spr = $spr
@onready var mover = $mover
@onready var solidcast = $mover/solidcast
@onready var maze : Maze = $"../Maze"
var vx : float; var vy : float;
var duck : bool = false;
var onladder_and_climbing : bool = false;
enum { JUMPBUF, FLORBUF, DUCKBUF, }

@onready var bufs : Bufs = Bufs.Make(self).setup_bufons(
	[JUMPBUF, 4, FLORBUF, 4, DUCKBUF, 4,]
)

func _physics_process(_delta: float) -> void:
	var dpad = Pin.get_dpad()
	var cell : Vector2i = maze.local_to_map(position)
	var celltid : int = maze.get_cell_tid(cell)
	var tomidcell : Vector2 = maze.map_to_center(cell) - position
	var onflor : bool = vy>=0 and mover.cast_fraction(
		self,solidcast,VERTICAL,1)<1
	var onladderbod : bool = celltid in [25,35]
	var onladdertop : bool = celltid == 15
	
	if Pin.get_plant_held() and duck and onflor: dpad.x = 0
	
	if dpad.y < 0 and onladderbod:
		onladder_and_climbing = true
	if dpad.y > 0 and onladderbod and !onflor:
		onladder_and_climbing = true
	if dpad.y > 0 and onladdertop:
		onladder_and_climbing = true
	
	if onladder_and_climbing and !(onladderbod or onladdertop):
		onladder_and_climbing = false # fall
	
	if onladder_and_climbing:
		#var tomidx = maze.map_to_center(cell).x - position.x
		#if tomidx < -3 and dpad.x > 0: dpad.x = 0
		#if tomidx >  3 and dpad.x < 0: dpad.x = 0
		if abs(tomidcell.x) > 1 and dpad.x == 0:
			dpad.x = sign(tomidcell.x)
		vx = move_toward(vx,dpad.x*0.25,0.1)
		vy = move_toward(vy,dpad.y*0.5,0.25)
	elif onflor:
		vx = move_toward(vx,dpad.x*0.5,0.15)
		vy = 0
	else:
		vx = move_toward(vx,dpad.x*0.5,0.03)
		vy = move_toward(vy,1.5,0.10)
	
	if onflor:bufs.on(FLORBUF)
	if Pin.get_jump_hit():bufs.on(JUMPBUF)
	if Pin.get_plant_hit():bufs.on(DUCKBUF)
	if bufs.try_eat([FLORBUF,JUMPBUF]):
		vy = -1.3
		# onflor = false # keep it true for 1 frame spr
	elif onflor and bufs.try_eat([DUCKBUF]) and not (onladdertop and onladder_and_climbing):
		duck = true
		vx = 0; vy = 0;
	if vx or vy<0:
		if duck: duck = false; vy = -0.8; # hop up
	if dpad.x:spr.flip_h=dpad.x<0
	
	if!mover.try_slip_move(self,solidcast,HORIZONTAL,vx):
		vx = 0
	
	if (
		onladder_and_climbing
			and
		((onladdertop and vy > 0) or onladderbod and vy < 0)
			and
		abs(tomidcell.x) <= 1
	):
		position.y += vy # ignore collisions vertically sometimes
	else:
		if!mover.try_slip_move(self,solidcast,VERTICAL,vy):
			vy = 0
			if onflor and onladderbod and onladder_and_climbing:
				onladder_and_climbing = false
	
	if onladder_and_climbing:
		if dpad:
			spr.setup([32,33,34,33],7)
		else: match spr.frame:
			34: spr.setup([34])
			_: spr.setup([32])
	elif!onflor: spr.setup([21])
	elif duck: spr.setup([30])
	elif dpad.x:
		if len(spr.frames)!=4: match spr.frame:
			21: spr.setup([22,23,24,21],8)
			_: spr.setup([21,22,23,24],8)
	else:
		if len(spr.frames)!=1: match spr.frame:
			21:pass
			_:spr.setup([20])
		else:
			spr.setup([20])
