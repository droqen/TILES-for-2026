extends Node2D

var loopbuf := 3
var screenshakebuf := 0

@export var maze : Maze
@export var player : Node2D
@onready var menu := NavdiMenuLevel.new("naut action menu",[
	[0, "GO_LF", go_try_or_check, [-1,0]],
	[1, "GO_RT", go_try_or_check, [ 1,0]],
	[2, "STUDY", study_try_or_check, []],
	[3, "CLIMB", go_try_or_check, [ 0,-1]],
	[4, "DSCND", go_try_or_check, [ 0, 1]],
	[5, null],
	[7, null],
	[8, "BREAK", break_try_or_check, []],
	[9, "EXIT ", exit_try_or_check, []],
])
@onready var menlen := len(menu.menuitems)

signal menu_choice_selected(id)

@onready var lblMenu : Label = $ViewRoot/LabelMenu
@onready var bgHint : ColorRect = $ViewRoot/bgTooltip
@onready var lblHint : Label = $ViewRoot/LabelTooltip
@onready var viewControl = $"../View"
@onready var root = $ViewRoot/Root

func set_hint(hint:String) -> void:
	lblHint.text = hint
	lblHint.visible_characters = 0
	bgHint.size.y = 0
	await lblHint.draw
	if hint == '': bgHint.size.y = 0
	else: bgHint.size.y = lblHint.get_visible_line_count()*5 + 1
func _ready() -> void:
	set_hint('')
	reprint()

var _looping := false
func loop_until_player_choice() -> void:
	_looping = true
	loopbuf = 3
	reprint()
	var id = await menu_choice_selected
	set_hint('')
	_looping = false
	reprint()
	
	var mitem = menu.menuitems[id]
	var _success := false
	if mitem[1]:
		_success = await mitem[2].call(mitem[3],true,true)
	
	# success.
	
	if is_instance_valid(player):
		var tcell := maze.local_to_map(player.position) + Vector2i(-1 if player.spr.flip_h else 1, 0)
		var target = Vector2i(0,0)
		if tcell.x < 0:
			target.x = -50
			while position.x > target.x:
				position.x -= 0.5
				viewControl.position = root.global_position
				await get_tree().physics_frame
		if tcell.x > 0:
			target.x = 0 # no need
			while position.x < target.x:
				position.x += 0.5
				viewControl.position = root.global_position
				await get_tree().physics_frame
	
func loop_show_tooltip(hint) -> void:
	set_hint(hint)
	while lblHint.visible_characters < len(lblHint.text):
		lblHint.visible_characters += 1
		await get_tree().physics_frame
	return # done

func reprint() -> void:
	lblMenu.text = ''
	for i in menlen:
		var mitem = menu.menuitems[i]
		var mname = mitem[1]
		var selected := (i == menu.selectionid and _looping)
		if mname:
			if not mitem[2].call(mitem[3],true,false):
				mname = null
		if selected:
			lblMenu.text += "[%s]" % [mname if mname else "     "]
		else:
			lblMenu.text += " %s " % [mname if mname else "     "]
		lblMenu.text += "\n\n"
func _physics_process(_delta: float) -> void:
	if _looping:
		var dy = Pin.get_dpad_tap().y
		if dy and menu.try_move(dy):
			reprint()
		if loopbuf > 0:
			loopbuf -= 1
		elif Pin.get_action_hit():
			menu_choice_selected.emit(menu.selectionid)
	if screenshakebuf > 0:
		screenshakebuf -= 1
		$ViewRoot.position.x = randi_range(-screenshakebuf,screenshakebuf)
		$ViewRoot.position.y = randi_range(-screenshakebuf,screenshakebuf)
enum {
	SPOT_ERROR,
	SPOT_BREAKABLE,
	SPOT_1, SPOT_2, SPOT_3, SPOT_4,
}

const INTERESTING_SPOTS := {
	Vector2i(0,2) : SPOT_BREAKABLE,
	Vector2i(0,8) : SPOT_BREAKABLE,
	Vector2i(5,8) : SPOT_1, # far right (bottom)
	Vector2i(-5,8): SPOT_1, # far left (bottom)
	#Vector2i(0,5) : SPOT_3, # weird little spot (ladder)
	Vector2i(4,4) : SPOT_4, # weird little spot (alcove)
}

func break_try_or_check(_args,check:bool=true,enact:bool=false) -> bool:
	if not is_instance_valid(maze) or not is_instance_valid(player): return false
	var pcell := maze.local_to_map(player.position)
	var tcell = pcell + Vector2i(-1 if player.spr.flip_h else 1, 0)
	if check:
		if lblHint.text == '' and not enact: return false
		if INTERESTING_SPOTS.get(tcell, SPOT_ERROR) != SPOT_BREAKABLE: return false
	if enact:
		$smash.play()
		await get_tree().create_timer(0.4).timeout
		maze.set_cell_tid(tcell, 4)
		screenshakebuf = 10
		await get_tree().create_timer(0.4).timeout
		#INTERESTING_SPOTS.erase(tcell)
		# should do some screenshake.
		await go_try_or_check([tcell.x-pcell.x,0],true,true)
	return true
func study_try_or_check(_args,check:bool=true,enact:bool=false) -> bool:
	if not is_instance_valid(maze) or not is_instance_valid(player): return false
	var pcell := maze.local_to_map(player.position)
	var tcell = pcell + Vector2i(-1 if player.spr.flip_h else 1, 0)
	if check:
		if not maze.get_cell_tid(tcell) == 2: return false # must be solid wall.
		if not INTERESTING_SPOTS.has(tcell): return false
	if enact:
		var spot = INTERESTING_SPOTS.get(tcell,SPOT_ERROR)
		match spot:
			SPOT_ERROR: await loop_show_tooltip("Error.")
			SPOT_BREAKABLE: await loop_show_tooltip("YOU COULD BREAK THIS WALL WITH A SUITABLE APPLICATION OF FORCE")
			SPOT_1: await loop_show_tooltip("THE WALL HERE IS MADE OF A SPACE AGE POLYMER")
			#SPOT_2: await loop_show_tooltip("NOTHING IN THE CORNER")
			#SPOT_3: await loop_show_tooltip("")
			SPOT_4: await loop_show_tooltip("A MONITOR DISPLAYS YOUR SCORE:\n           \n    0")
	return true
func exit_try_or_check(_args,check:bool=true,enact:bool=false) -> bool:
	if not is_instance_valid(maze) or not is_instance_valid(player):
		$ViewRoot/LabelMenu/ExitSquare.hide()
		return false
	var pcell := maze.local_to_map(player.position)
	if check:
		match maze.get_cell_tid(pcell):
			99: pass
			_:
				$ViewRoot/LabelMenu/ExitSquare.hide()
				return false
	if enact:
		player.queue_free()
	$ViewRoot/LabelMenu/ExitSquare.show()
	return true
func go_try_or_check(args,check:bool=true,enact:bool=false) -> bool:
	if not is_instance_valid(maze) or not is_instance_valid(player): return false
	var dx : int = args[0]
	var dy : int = args[1]
	var dxy : Vector2i = Vector2i(dx,dy)
	var pcell := maze.local_to_map(player.position)
	if check:
		match maze.get_cell_tid(pcell + dxy):
			0,3,4,5,13,99: pass
			1,2: return false
			_: print("unknown"); return false;
		if dy < 0: if maze.get_cell_tid(pcell) != 13: return false;
	if enact:
		if dx:
			pcell += Vector2i(dx,0)
			await player.loop_walk_to(maze.map_to_local(pcell))
		if dy:
			pcell += Vector2i(0,dy)
			await player.loop_climb_to(maze.map_to_local(pcell))
			#
		#var playerspr : SheetSprite = player.get_node("Spr")
		#if dx:
			#playerspr.flip_h = dx < 0
		#if dy:
			#playerspr.setup([20,21],40)
		#else:
			#playerspr.setup([10,11],50)
		
		var onfloor := false
		var MAXFALL := 10
		var fall := 0
		while not onfloor and fall < MAXFALL:
			match maze.get_cell_tid(pcell+Vector2i.DOWN):
				1,2,13: onfloor = true
				_: pcell += Vector2i.DOWN; fall += 1;
		if fall:
			await player.loop_fall_to(maze.map_to_local(pcell))
	return true
