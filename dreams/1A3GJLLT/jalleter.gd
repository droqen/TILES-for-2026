extends NavdiSolePlayerBasics

@onready var maze : Maze = $"../Maze"

var bonky := false
var ducky := false
enum {DUCKYSTARTBUF}

func _ready() -> void:
	super._ready()
	bufs.setup_bufons([DUCKYSTARTBUF,10])

func _physics_process(_delta: float) -> void:
	if not visible: return
	
	var dpad := Pin.get_dpad()
	var onfloor := is_on_floor()
	if Pin.get_jump_hit(): bufs.on(JUMPBUF)
	
	if ducky != (onfloor and dpad.y > 0):
		ducky = !ducky
		if ducky: bufs.on(DUCKYSTARTBUF)
		else: vy = -1.0
	
	if ducky:
		vx *= 0.9
	elif bonky and dpad.x == 0:
		vx *= 0.95
	else:
		tow_vx(dpad.x, 1.0, 0.1 if onfloor else 0.15, false)
	tow_gravity(2.2, 0.04, Pin.get_jump_held() or bonky, 0.05)
	if bonky: bonky = vy < 0
	apply_velocities()
	
	if position.x < 3: vx = vx*0.5+0.2
	if position.x > 190-3: vx = vx*0.5-0.2
	
	# spr - stay the same
	
	if bufs.try_eat([JUMPBUF,FLORBUF]):
		vy = -1.8
	
	if ducky:
		if bufs.has(DUCKYSTARTBUF):
			spr.setup([4,5],5)
		else:
			spr.setup([14,15,],20)
	elif bufs.has(LANDBUF):
		spr.setup([4])
	elif dpad.x:
		spr.setup([10,11,12,13],8)
	else:
		spr.setup([10,17],11)
	var white : int = 0
	for dx in [-2,2]:
		for dy in [-2,2]:
			if maze.get_cell_tid(maze.local_to_map(position + Vector2(dx,dy))) == 99:
				white += 1
	if white >= 4:
		hide()
		var whitecells := maze.get_used_cells_by_tids([99])
		for i in 10:
			if !is_instance_valid(maze): break
			for cell in whitecells:
				maze.set_cell_tid(cell, 98 + i % 2)
			if !is_inside_tree(): break
			await get_tree().create_timer(0.02).timeout
		if is_inside_tree():
			queue_free()
