extends NavdiSolePlayerBasics

@onready var maze = $"../Maze"
@onready var descend_sfx = $"../descend"

enum { HEADBONKBUF, KILLFREEZBUF, }

func _ready() -> void:
	super._ready()
	bufs.setup_bufons([HEADBONKBUF,8,KILLFREEZBUF,15,])

func _physics_process(_delta: float) -> void:
	if bufs.has(KILLFREEZBUF): return
	var dpad := Pin.get_dpad()
	var onfloor := is_on_floor()
	if Pin.get_jump_hit(): bufs.on(JUMPBUF)
	tow_vx(dpad.x, 1.0, 0.1, )
	if bufs.has(HEADBONKBUF):
		vy = 0
	elif onfloor or bufs.has(FLORBUF):
		vy = 0
		if dpad.y > 0: vy = 0.1
	else:
		tow_gravity(1.0, 0.02, Pin.get_jump_held(),0.04)
	var might_headbonk : bool = (vy<0)
	apply_velocities()
	if might_headbonk and vy == 0: bufs.on(HEADBONKBUF)
	if bufs.try_eat([JUMPBUF,FLORBUF]):
		vy = -1.0
	if bufs.has(HEADBONKBUF):
		spr.setup([23])
	elif bufs.has(TURNBUF):
		spr.setup([13])
	elif !onfloor:
		spr.setup([20,21,22],9)
	elif bufs.has(LANDBUF):
		spr.setup([14])
	elif dpad.x:
		spr.setup_forcechangeindex([10,11],10)
	elif dpad.y > 0:
		spr.setup([24])
	else:
		spr.setup_trywaitformatch([10])
	
	if maze.get_cell_tid(maze.local_to_map(position)) == 99:
		queue_free()
		descend_sfx.play()

func _on_otherkiller_area_entered(other_area: Area2D) -> void:
	if other_area.try_kill():
		get_node(other_area.name + "killed").play()
		bufs.on(KILLFREEZBUF)
