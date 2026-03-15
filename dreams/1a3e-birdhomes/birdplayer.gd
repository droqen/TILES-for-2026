extends NavdiSolePlayerBasics

const BIRDHOP_BEEP : String = &"https://www.beepbox.co/#9n11sbk0l00e00t43a7g00j01r1i0o5T5v1u05f0qwx10n512d06H-IHyiih9999998h0E1b6T4v1uf0f0q011z6666ji8k8k3jSBKSJJAArriiiiii07JCABrzrrrrrrr00YrkqHrsrrrrjr005zrAqzrjzrrqr1jRjrqGGrrzsrsA099ijrABJJJIAzrrtirqrqjqixzsrAjrqjiqaqqysttAJqjikikrizrHtBJJAzArzrIsRCITKSS099ijrAJS____Qg99habbCAYrDzh00E0bkp18Fli08uww"
const POPSOUND_BEEP : String = &"https://www.beepbox.co/#9n11s0k0l00e00t2ma7g00j07r1i0o5T0v4u00f0qM012d04w1h0E0T2v1u02f10w4qw02d03w2E0b4gp1hIWXdVifgg54FMZ100"
@onready var maze = $"../Maze"

func play_pop_sound() -> void:
	Beeper.play_sfx(POPSOUND_BEEP)

func _ready() -> void:
	super._ready()
	bufs.setup_bufons([LANDBUF,8,])

func popbubble(cell:Vector2i) -> void:
	play_pop_sound()
	maze.set_cell_tid(cell,99)
	await get_tree().create_timer(0.1).timeout
	if is_instance_valid(maze):
		maze.set_cell_tid(cell,0)

func _physics_process(_delta: float) -> void:
	if maze.get_cell_tid(maze.local_to_map(position)) in [18,28,38]:
		popbubble(maze.local_to_map(position))
	if maze.get_cell_tid(maze.local_to_map(position)) == 29:
		maze.set_cell_tid(maze.local_to_map(position), 0)
		queue_free() # bye
		return
	var dpad := Pin.get_dpad()
	var onfloor := is_on_floor()
	var ducking := onfloor and (dpad.y>0 or bufs.has(LANDBUF))
	if Pin.get_jump_hit(): bufs.on(JUMPBUF)
	tow_vx(dpad.x, 1.0, 0.2 if onfloor else 0.1)
	tow_gravity(2.3, 0.03, Pin.get_jump_held(), 0.08)
	apply_velocities()
	if position.x < 3 and vx < 0:
		position.x += 230-6
	if position.x >= 230-3 and vx > 0:
		position.x -= 230-6
	if bufs.try_eat([JUMPBUF, FLORBUF]):
		Beeper.play_sfx(BIRDHOP_BEEP)
		vy = -1.3
	
	if !onfloor:
		if vy >= 0:
			spr.setup([26,27],12)
		else:
			spr.setup([16,17],8)
	else:
		var d : int = 10 if ducking else 0
		if bufs.has(TURNBUF):
			spr.setup([12+d])
		elif dpad.x:
			spr.setup([13+d,14+d],8)
		else:
			spr.setup([10+d,10+d,11+d],15)
		
	if position.y > 164:
		var beep = get_tree().get_first_node_in_group(NavdiBeeper.BEEPER_BEEP_GROUP)
		print("beep? ",beep)
		if beep and beep is NavdiBeep:
			print("beep silenced")
			(beep as NavdiBeep).url = ''
		else:
			var silence_beep = NavdiBeep.new()
			silence_beep.url = ''
			Dreamer.spawn(silence_beep)
			print("created silence beep")
		$"../Label".gradually_delete()
		queue_free()
		
