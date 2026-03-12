extends NavdiSolePlayerBasics

var crowch : int = false
var crowch_counter : int = 0
var crowch_counter_max : int = 100

func get_maze_aligned_floor_x() -> int:
	var algnxleft : int = floor((position.x-5)/10)*10 + 5
	var algnxrite : int = ceil((position.x-5)/10)*10 + 5
	var algnxtotest := [algnxleft, algnxrite]
	if algnxleft == algnxrite: algnxtotest = [algnxleft]
	if abs(algnxleft-position.x)>5: algnxtotest = [algnxrite, algnxleft]
	var x : float = position.x
	for algnx in algnxtotest:
		position.x = algnx
		if mover.cast_fraction(self, solidcast, VERTICAL, 10) < 1:
			# floor found at algnx.
			position.x = x
			return algnx
	position.x = x
	return algnxtotest[0] # default is closest.

func _ready() -> void:
	super._ready()
	bufs.setup_bufons([
		TURNBUF,10,
		FLORBUF,8,
		LANDBUF,8,
	])
func _physics_process(_delta: float) -> void:
	var dpad = Pin.get_dpad()
	if Pin.get_jump_hit(): bufs.on(JUMPBUF)
	var onfloor := is_on_floor()
	if dpad.y > 0 and onfloor:
		var to_aligned_x : float = get_maze_aligned_floor_x() - position.x
		if abs(to_aligned_x) < 1:
			crowch = true
			position.x = get_maze_aligned_floor_x()
		elif dpad.x == 0:
			dpad.x = sign(to_aligned_x)
	if crowch:
		if dpad.y <= 0: crowch = false; vy = -0.3
		if dpad.x != 0: dpad.x = 0 # stop
		if !onfloor: crowch = false
		if crowch_counter < crowch_counter_max:
			crowch_counter += 1
	else:
		crowch_counter = 0
	tow_vx(dpad.x, 1.0, 0.1 if onfloor else 0.03)
	if !onfloor: tow_gravity(3.0, 0.015, Pin.get_jump_held(), 0.03)
	apply_velocities()
	if !onfloor:
		spr.setup([11])
	elif crowch:
		if crowch_counter < crowch_counter_max:
			spr.setup([16,16,17,17,18,19],5)
		else:
			spr.setup([16])
	elif bufs.has(TURNBUF):
		spr.setup([13])
	elif bufs.has(LANDBUF):
		spr.setup([14])
	elif dpad.x:
		spr.setup_forcechangeindex([10,11,10,12], 6, {11:2,14:3})
	else:
		spr.setup_trywaitformatch([10])
	
	if bufs.try_eat([JUMPBUF, FLORBUF]):
		vy = -1.0
		#onfloor = false
