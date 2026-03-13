extends NavdiSolePlayerBasics

enum { PLANTHIT_BUF, }

var pinheld_plant : bool = false
var duck : bool = false
var duck_targetcell : Vector2i
var duck_targetcellpos : Vector2
var planting : bool = false
var planting_progress : int = 0

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

func jump() -> void:
	exit_duck()
	vy = -1.0
func enter_duck() -> void:
	if !duck:
		duck = true
		duck_targetcell.x = int(floor(position.x / 10))
		duck_targetcell.y = int(floor(position.y / 10) + 1)
		duck_targetcellpos.x = duck_targetcell.x * 10 + 5
		duck_targetcellpos.y = duck_targetcell.y * 10 + 5
		
		planting = true
		planting_progress = 1
func exit_duck() -> void:
	if duck:
		duck = false
		pinheld_plant = false
		if vy > -0.3: vy = -0.3 # don't cancel a jump
func planthit() -> void:
	planting_progress = 0
	bufs.on(PLANTHIT_BUF)
	print("boop! @ ",duck_targetcell)
	for i in range(2):
		var flash = Dreamer.spawn(
			load("res://dreams/12-connection/player_dig_flash.tscn"),
		).setup_pos(duck_targetcellpos)
		if i == 0:
			await get_tree().create_timer(0.075).timeout
		else:
			flash.n.get_node("ColorRect").color = Color.BLACK
			await get_tree().create_timer(0.075).timeout
		if is_instance_valid(flash.n):
			flash.n.queue_free()

func _ready() -> void:
	super._ready()
	bufs.setup_bufons([
		TURNBUF,10,
		FLORBUF,8,
		LANDBUF,8,
		PLANTHIT_BUF,8,
	])
func _physics_process(_delta: float) -> void:
	var dpad = Pin.get_dpad()
	if Pin.get_jump_hit(): bufs.on(JUMPBUF)
	if Pin.get_plant_hit(): pinheld_plant = true
	if !Pin.get_plant_held(): pinheld_plant = false
	var onfloor := is_on_floor()
	if pinheld_plant and onfloor:
		var to_aligned_x : float = get_maze_aligned_floor_x() - position.x
		if abs(to_aligned_x) < 1:
			enter_duck()
		elif dpad.x == 0:
			dpad.x = sign(to_aligned_x)
	if duck:
		# locked in position
		position.x = duck_targetcellpos.x
		vx = 0; vy = 0;
		if bufs.has(PLANTHIT_BUF):
			pass # we're stuck here
		else:
			if((dpad.x != 0 and not pinheld_plant)
			or (not onfloor)): exit_duck()
			elif planting_progress == 0 and not pinheld_plant:
				exit_duck()
			else:
				if dpad.x != 0: dpad.x = 0 # stop
				planting = true # pinheld_plant
				if planting:
					planting_progress += 1
					if planting_progress >= 30:
						planthit()
	
	tow_vx(dpad.x, 1.0, 0.1 if onfloor else 0.03)
	if duck: vx = 0
	if !onfloor: tow_gravity(3.0, 0.015, Pin.get_jump_held(), 0.03)
	apply_velocities()
	if !onfloor:
		spr.setup([11])
	elif duck:
		if bufs.has(PLANTHIT_BUF):
			spr.setup([19])
		elif planting:
			spr.setup([16,17,18], 10)
		else:
			spr.setup([16,17,18], 0)
	elif bufs.has(TURNBUF):
		spr.setup([13])
	elif bufs.has(LANDBUF):
		spr.setup([14])
	elif dpad.x:
		spr.setup_forcechangeindex([10,11,10,12], 6, {11:2,14:3})
	else:
		spr.setup_trywaitformatch([10])
	
	if bufs.try_eat([JUMPBUF, FLORBUF]):
		jump()
