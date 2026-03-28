extends NavdiSolePlayerBasics

@onready var sprcopy = $sprcopy

func _ready() -> void:
	super._ready()
	sprcopy.playing = false
	spr.frame_changed.connect(func(): sprcopy.frame = spr.frame)

func _physics_process(_delta: float) -> void:
	position.x = fposmod(position.x, 100)
	sprcopy.position.x = 99 if position.x < 50 else -99
	
	var dpad = Pin.get_dpad()
	var onfloor := is_on_floor()
	var duck := onfloor and Pin.get_plant_held()
	if Pin.get_jump_hit(): bufs.on(JUMPBUF)
	if duck:
		dpad.x = 0
		vx *= 0.9
	else:
		tow_vx(dpad.x,1.0,0.1 if onfloor else 0.05)
		sprcopy.flip_h = spr.flip_h
	if bufs.has(TURNBUF):
		if not onfloor:
			vy = move_toward(vy, -0.5, 0.05)
	else:
		tow_gravity(1.0,0.04,Pin.get_jump_held(),0.05)
	apply_velocities()
	if !onfloor:
		if bufs.has(TURNBUF):
			for _spr in [spr,sprcopy]:
				_spr.setup([24])
		else:
			for _spr in [spr,sprcopy]:
				_spr.setup([13])
	elif duck:
		if bufs.has(TURNBUF):
			for _spr in [spr,sprcopy]:
				_spr.setup([21])
		else:
			if not (spr.frame in [21,23,13]):
				for _spr in [spr,sprcopy]:
					_spr.setup([25,23], 5)
			else:
				for _spr in [spr,sprcopy]:
					_spr.setup([23])
	else:
		if bufs.has(TURNBUF):
			for _spr in [spr,sprcopy]:
				_spr.setup([20])
		elif dpad.x:
			for _spr in [spr,sprcopy]:
				_spr.setup_forcechangeindex([11,14,11,15],6)
		else:
			for _spr in [spr,sprcopy]:
				_spr.setup_trywaitformatch([10])
	if bufs.try_eat([JUMPBUF,FLORBUF,]):
		vy = -1.5
