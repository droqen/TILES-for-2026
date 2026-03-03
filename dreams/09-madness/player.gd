extends NavdiSolePlayerBasics

func _ready() -> void:
	setup_basic_child_nodes(
		#"spr","mover","mover/solidcast"
	)

func _physics_process(_delta: float) -> void:
	Dreamer.navdilog("09-player", str(position))
	var dpad := Pin.get_dpad()
	facedir = dpad.x
	if Pin.get_jump_hit(): bufs.on(JUMPBUF)
	var _onfloor : bool = is_on_floor()
	tow_vx(dpad.x, 1.0, 0.35)
	tow_gravity(2.0, 0.10, Pin.get_jump_held(), 0.08)
	if bufs.try_eat([JUMPBUF,FLORBUF]):
		# jump
		vy = -1.7
		_onfloor = false
	apply_velocities()
