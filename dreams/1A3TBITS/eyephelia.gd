extends NavdiSolePlayerBasics

enum {DIGGINGBUF}

signal dug(dcell : Vector2i)

var jumped : bool = false
var digpressed : bool = false

@onready var maze : Maze = $"../Maze"

func _ready() -> void:
	super._ready()
	bufs.setup_bufons([DIGGINGBUF, 20, ])

func _physics_process(_delta: float) -> void:
	if position.x < -5 or position.x > 205: queue_free(); return;
	var pcell = maze.local_to_map(position)
	if maze.get_cell_tid(pcell) == 18:
		dig(pcell)
		for dir in [Vector2i.DOWN,Vector2i.UP,Vector2i.LEFT,Vector2i.RIGHT]:
			if maze.get_cell_tid(pcell+dir) == 0:
				dig(pcell+dir)
	var dpad := Pin.get_dpad()
	var onfloor := is_on_floor()
	if onfloor: jumped = false
	if Pin.get_plant_hit(): digpressed = true
	if digpressed: digpressed = Pin.get_plant_held()
	if Pin.get_jump_hit(): bufs.on(JUMPBUF)
	if bufs.has(DIGGINGBUF):
		digpressed = false
		bufs.clr(JUMPBUF)
		bufs.clr(TURNBUF)
		if !onfloor: bufs.clr(DIGGINGBUF)
		vx *= 0.8
	else:
		tow_vx(dpad.x,0.75,0.1)
	tow_gravity(1.00, 0.0275,
		jumped and Pin.get_jump_held(), 0.04)
	apply_velocities()
	if vy < 0 and position.y < 5:
		vy = 0; position.y = 5
	if bufs.has(DIGGINGBUF):
		spr.setup([13,14,15,14,15],4,)
		if bufs.read(DIGGINGBUF) == 1:
			vy = -0.4 # hop!
			dig()
	elif bufs.on(TURNBUF): spr.setup([12])
	elif !onfloor: spr.setup([11])
	elif dpad.x:
		spr.setup_forcechangeindex([10,11],8)
	else: spr.setup_trywaitformatch([10])
	if bufs.try_eat([JUMPBUF,FLORBUF]):
		vy = -1.5
		jumped = true
	elif onfloor and digpressed:
		bufs.on(DIGGINGBUF)
		# get to diggin'
		# maybe center on the cell?

func dig(dcell : Vector2i = Vector2i(-1,-1)) -> void:
	if dcell.x < 0 and dcell.y < 0:
		var pcell := maze.local_to_map(position)
		dcell = pcell + Vector2i(0,1)
	var tid := maze.get_cell_tid(dcell)
	dug.emit(dcell)
	maze.set_cell_tid(dcell, 24)
	await get_tree().process_frame
	if not is_instance_valid(maze): return
	maze.set_cell_tid(dcell, 25)
	await get_tree().process_frame
	if not is_instance_valid(maze): return
	maze.set_cell_tid(dcell, 26)
	await get_tree().create_timer(.04).timeout
	if not is_instance_valid(maze): return
	maze.set_cell_tid(dcell, 27)
	await get_tree().create_timer(.04).timeout
	if not is_instance_valid(maze): return
	maze.set_cell_tid(dcell, 0)
