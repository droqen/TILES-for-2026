extends NavdiSolePlayerBasics

@export var maze : Maze
@onready var booksim = $"../booksim"
@onready var booklabels = $"../BookLabels"

var climbing : bool = false

func gettidhere() -> int:
	return gettidat(Vector2.ZERO)
func gettidhereorbookbelow() -> int:
	var tid := gettidat(Vector2.ZERO)
	if tid not in [3,4,5,6]:
		tid = gettidat(Vector2(0,5))
	return tid
func getbookhereorbookbelow():
	var cells = [
		maze.local_to_map(position),
		maze.local_to_map(position + Vector2(0,5)),
	]
	for cell in cells:
		var found_book = booksim.get_book_at_cell(cell)
		if found_book: return [found_book,maze.map_to_local(cell)] # returns book and book's position.
	return null
func gettidat(plus : Vector2) -> int:
	return maze.get_cell_tid(maze.local_to_map(position + plus))



var book = null
var bookcenterpos : Vector2

enum { BOOKABUF = 80054837 }

func set_booka(booka)->void:
	if booka is Array:
		bufs.on(BOOKABUF)
		var clamped_booka = Vector2(clamp(booka[1].x,-15+50+5,315-50-5), booka[1].y)
		if book != booka[0] or bookcenterpos != booka[1]:
			book = booka[0]
			bookcenterpos = booka[1]
			booklabels.show_book(book, clamped_booka)
	else:
		book = null

func _ready() -> void:
	super._ready()
	bufs.setup_bufons([BOOKABUF,3])

func _physics_process(_delta: float) -> void:
	
	if not bufs.has(BOOKABUF): book = null; booklabels.hide_book();
	
	var dpad := Pin.get_dpad()
	var onfloor := is_on_floor()
	var duck := not climbing and onfloor and (Pin.get_dpad().y > 0 or Pin.get_plant_held())
	if climbing:
		match gettidhereorbookbelow():
			3,4,5,6:
				if onfloor and dpad.y > 0: climbing = false; duck = true;
				# else pass - you're on a book. it's fine, keep climbin.
				var booka = getbookhereorbookbelow()
				if booka is Array and not dpad:
					set_booka(booka)
			_: climbing = false
	else:
		if dpad.y and not duck:
			match gettidhere():
				3,4,5,6: # book
					climbing = true
		if not climbing and Pin.get_jump_hit(): bufs.on(JUMPBUF)
	#if Pin.get_jump_hit(): bufs.on(JUMPBUF)
	
	var applyflip : bool = true
	
	if dpad.x == 0 and dpad.y == 0 and book:
		var to_bcp = bookcenterpos - position
		if abs(to_bcp.x) > 0.35: dpad.x = sign(to_bcp.x); applyflip = false
		if abs(to_bcp.y) > 0.35: dpad.y = sign(to_bcp.y)
	
	if climbing: tow_vx( dpad.x , 0.35 , 0.1  , applyflip )
	elif duck:   tow_vx( dpad.x , 0.0  , 0.05 , )
	elif!onfloor:vx *= 0.99
	else:        tow_vx( dpad.x , 0.70 , 0.2  , )
	if climbing:
		vy = move_toward(vy, dpad.y * 0.25, 0.1)
	else:
		tow_gravity(1.5, 0.02)
	apply_velocities()
	
	if climbing:
		if dpad:
			spr.setup_forcechangeindex([16,17,18,19],8,{18:19})
		else:
			spr.setup_trywaitformatch([16,18],0)
	elif !onfloor:
		if bufs.has(TURNBUF):
			spr.setup([21],0)
		else:
			spr.setup([11],0)
	elif duck:
		if bufs.has(TURNBUF):
			spr.setup([22],0)
		else:
			spr.setup([12],0)
	elif bufs.has(LANDBUF):
		spr.setup([12],0)
	else:
		if bufs.has(TURNBUF):
			spr.setup([20],0)
		elif dpad.x:
			spr.setup_forcechangeindex([11,10],10)
		else:
			spr.setup_trywaitformatch([10],0)
	
	if bufs.try_eat([JUMPBUF, FLORBUF]): vy = -0.50
	
	if gettidhere() == 99 and position.x < -4: queue_free()
