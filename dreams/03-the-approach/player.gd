extends Node2D

@onready var spr = $spr
@onready var mover = $mover
@onready var solidcast = $mover/solidcast
var vx : float; var vy : float;
var duck : bool = false;
enum { JUMPBUF, FLORBUF, DUCKBUF, }

@onready var bufs : Bufs = Bufs.Make(self).setup_bufons(
	[JUMPBUF, 4, FLORBUF, 4, DUCKBUF, 4,]
)

func _physics_process(_delta: float) -> void:
	var dpad = Pin.get_dpad()
	var onflor : bool = vy>=0 and mover.cast_fraction(
		self,solidcast,VERTICAL,1)<1
	
	if Pin.get_plant_held() and duck: dpad.x = 0
	
	if onflor:
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
	elif onflor and bufs.try_eat([DUCKBUF]):
		duck = true
		vx = 0; vy = 0;
	if vx or vy<0:
		if duck: duck = false; vy = -0.8; # hop up
	if dpad.x:spr.flip_h=dpad.x<0
	if!mover.try_slip_move(self,solidcast,HORIZONTAL,vx):
		vx = 0
	if!mover.try_slip_move(self,solidcast,VERTICAL,vy):
		vy = 0
	
	if!onflor: spr.setup([21])
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
