extends NavdiSolePlayerBasics

enum { WALLPUSHINGBUF, FREEZBUF, }
var wallpushingdir := 0
var jumps := 1
var onfloor := false
var is_frozen : bool :
	get : return bufs.has(FREEZBUF)
func _ready() -> void:
	super._ready()
	bufs.setup_bufons([WALLPUSHINGBUF,4,FREEZBUF,3])

func freeze() -> void:
	bufs.on(FREEZBUF)

func _physics_process(_delta: float) -> void:
	if Pin.get_jump_hit(): bufs.on(JUMPBUF)
	onfloor = is_on_floor()
	if bufs.has(FREEZBUF):
		spr.ani_subindex -= 1 # aaa will this even work
		if bufs.has(JUMPBUF): bufs.on(JUMPBUF)
		return
	var dpad := Pin.get_dpad()
	if onfloor: jumps = 1
	tow_vx(dpad.x, 0.8, 0.05)
	if bufs.has(WALLPUSHINGBUF) and dpad.x == wallpushingdir:
		vx = dpad.x * 0.3
	tow_gravity(1.2, 0.033)
	if jumps > 0 and bufs.try_eat([JUMPBUF]):
		jumps -= 1
		vy = -1.2
	#apply_velocities()
	if!mover.try_slip_move(self,solidcast,HORIZONTAL,vx):
		vx=0
	if dpad.x: mover.try_slip_move(self,solidcast,HORIZONTAL,dpad.x)
	if!mover.try_slip_move(self,solidcast,VERTICAL,vy):
		vy=0
	if dpad.x: mover.try_move(self,solidcast,HORIZONTAL,-dpad.x)
	#if dpad.x and mover.cast_fraction(self, solidcast, HORIZONTAL, dpad.x) < 1:
		#bufs.on(WALLPUSHINGBUF)
		#wallpushingdir = dpad.x
	
	if !onfloor:
		if jumps > 0:
			spr.setup([42,43],8)
		else:
			spr.setup([33])
	elif dpad.x:
		spr.setup_forcechangeindex([32,33],8)
	else:
		spr.setup_trywaitformatch([32])
