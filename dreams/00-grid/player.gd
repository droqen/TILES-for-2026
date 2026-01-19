extends NavdiSolePlayer

@onready var spr : SheetSprite = $spr
@onready var mover : NavdiBodyMover = $mover
@onready var solidcast : ShapeCast2D = $mover/solidcast

enum {
	FLORBUF,
	JUMPBUF,
	ROLLBUF,
}

var vx : float; var vy : float; var tumblin : bool = false;

@onready var bufs : Bufs = Bufs.Make(self).setup_bufons([FLORBUF,4,JUMPBUF,4,ROLLBUF,4,])

func _physics_process(_delta: float) -> void:
	var dpad : Vector2 = Pin.get_dpad()
	var onfloor : bool = vy >= 0 and mover.cast_fraction(self, solidcast, VERTICAL, 1.5) < 1
	if tumblin and dpad.x == 0:
		pass
	else:
		vx = move_toward(vx, dpad.x*0.9, 0.13)
	vy = move_toward(vy, 2.0, 0.05)
	if vy < 0 and !Pin.get_jump_held(): vy += 0.07
	if onfloor: vy = 0; bufs.on(FLORBUF)
	if Pin.get_jump_hit(): bufs.on(JUMPBUF)
	if onfloor and Pin.get_plant_held(): tumblin = true
	else: tumblin = false
	
	if dpad.x:
		spr.flip_h = dpad.x < 0
		$pink.position.x = -5 if spr.flip_h else -4
	
	if !onfloor:
		spr.setup([11])
	elif tumblin:
		if vx:
			spr.setup([21,22,23,24],8)
		else:
			spr.setup([24])
	elif dpad.x:
		if len(spr.frames) != 4:
			match spr.frame:
				11, 12:
					spr.setup([10,12,10,11],8)
				_:
					spr.setup([11,10,12,10],8)
	else: spr.setup([10])
	
	if bufs.try_eat([FLORBUF, JUMPBUF]):
		vy = -1.5
		onfloor = false
		tumblin = false
		
	if!mover.try_slip_move(self, solidcast, HORIZONTAL, vx):
		vx = 0
	if!mover.try_slip_move(self, solidcast, VERTICAL, vy):
		vy = 0
