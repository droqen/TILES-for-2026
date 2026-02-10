extends NavdiSolePlayer

enum { JUMPBUF, FLORBUF, }

@onready var spr = $spr
@onready var mover = $mover
@onready var solidcast = $mover/solidcast
@onready var bufs = Bufs.Make(self).setup_bufons([
	JUMPBUF, 4, FLORBUF, 8,
])
var vx : float; var vy : float;

func _physics_process(_delta: float) -> void:
	var dpad = Pin.get_dpad()
	var jumphit = Pin.get_jump_hit()
	var jumpheld = Pin.get_jump_held()
	var onfloor:bool = mover.cast_fraction(self,solidcast,VERTICAL,1)<1
	if jumphit: bufs.on(JUMPBUF)
	if onfloor: bufs.on(FLORBUF)
	if dpad.x: spr.flip_h = dpad.x < 0
	vx=move_toward(vx,dpad.x*1.0,0.2)
	vy=move_toward(vy,2.0,0.04)
	if vy<0 and !jumpheld:vy+=0.06
	
	if bufs.try_eat([JUMPBUF,FLORBUF]):
		onfloor = false
		vy = -1.3
	
	if!mover.try_slip_move(self, solidcast, HORIZONTAL, vx):
		vx=0
	if!mover.try_slip_move(self, solidcast, VERTICAL, vy):
		vy=0
	
	if !bufs.has(FLORBUF):
		spr.setup([2])
	elif dpad.x:
		if len(spr.frames) == 1: match spr.frame:
			1: spr.setup([2,1,3,1],8)
			_: spr.setup([1,2,1,3],8)
	else:
		if len(spr.frames) == 4: match spr.frame:
			1: spr.setup([1])
			_: pass
		else:
			spr.setup([1])
	
	if Pin.get_jump_hit(): bufs.on(JUMPBUF)
