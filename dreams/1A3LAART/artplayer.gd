extends NavdiSolePlayerBasics

enum { SQUATBUF, FLASHINGBUF, }

var gaaaaah : bool = false

var squatting : bool = false
var squatcharge : int = 0

func push_x(dx:float) -> void:
	if dx == 0: return
	if!mover.try_slip_move(self, solidcast, HORIZONTAL, dx) or position.x <= -4:
		bufs.on(FLASHINGBUF)

func _ready() -> void:
	super._ready()
	bufs.setup_bufons([SQUATBUF,10,FLASHINGBUF,20,])
func _physics_process(_delta: float) -> void:
	
	gaaaaah = bufs.has(FLASHINGBUF)
	
	var dpad = Pin.get_dpad()
	var onfloor := is_on_floor()
	if Pin.get_jump_hit(): bufs.on(JUMPBUF)
	if Pin.get_plant_hit(): bufs.on(SQUATBUF)
	if onfloor and bufs.has(SQUATBUF) and not bufs.has(FLASHINGBUF):
		squatting = true
		squatcharge = 1
	if squatting:
		if not onfloor: squatting = false; vy = -0.3
		squatcharge += 1
		dpad *= 0
		vx = 0
		vy = 0
		if squatcharge < 5:
			pass # stuck
		elif !Pin.get_plant_held() or squatcharge > 40:
			if squatcharge > 10:
				bufs.on(FLASHINGBUF)
			squatting = false
			bufs.clr(FLORBUF)
			vy = -0.5
			onfloor = false
	tow_vx(dpad.x, 1, 0.1)
	if bufs.has(FLASHINGBUF):
		vx *= 0.9
		vy *= 0.9
		# transformation
	else:
		#tow_gravity(1.0, 0.07)
		tow_gravity(1.0, 0.035, Pin.get_jump_held(), 0.045)
	apply_velocities()
	position.x = clamp(position.x, -4, 104)
	if position.y > 105: position.y = -5
	if bufs.try_eat([JUMPBUF, FLORBUF]):
		vy = -1.3
		
	if bufs.has(FLASHINGBUF):
		if bufs.has(TURNBUF):
			spr.setup([35])
		else:
			if spr.frame in [33,34] and randf() < 0.5:
				pass
			else:
				spr.setup([[15,15,15,15,15,15,33,34][randi()%8]])
	elif !onfloor:
		spr.setup([12])
	elif squatting:
		if squatcharge < 5:
			spr.setup([14])
		elif squatcharge <= 10:
			spr.setup([17])
		else:
			spr.setup([16,17],3)
	elif bufs.has(TURNBUF):
		spr.setup([13])
	elif dpad.x:
		spr.setup_forcechangeindex([10,11],10)
	else:
		spr.setup_trywaitformatch([10])
	
