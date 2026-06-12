extends Node2D

signal died

var vx : float = 0
var dir : int = 0
const MIN_X := 0
const DELETE_AT_X_PAST := 490
const HEADBUTT_X := 485

@onready var maze : Maze = $"../Maze"
@onready var deathrattle : NavdiBeep = $"../bgm_deathrattle"

var lastminicellx : int = 0

func _physics_process(_delta: float) -> void:
	var minicellx : int = floor(position.x / 5)
	if minicellx != lastminicellx:
		lastminicellx = minicellx
		var p := position
		for spr in $sprites.get_children():
			if position.x+spr.position.x > 96: continue;
			else: p += spr.position; break;
		var cell := maze.local_to_map(p+Vector2(2,2))
		print(minicellx, cell)
		match minicellx % 2:
			0:
				match maze.get_cell_tid(cell):
					10:
						maze.set_cell_tid(cell, 12)
						$chomp.play()
					11:
						maze.set_cell_tid(cell, 13)
						$chomp.play()
			1:
				match maze.get_cell_tid(cell):
					10,11,12,13:
						maze.set_cell_tid(cell, -1)
						$chomp.play()
	var ffwd := pow(position.x / DELETE_AT_X_PAST, 1.5)
	$bgm_notes.tempo = lerp(103, 459, ffwd)
	
	if wallhp > 0:
		var dpad := Pin.get_dpad_tap()
		if dpad.x : dir = dpad.x
	else: pass #no control
	vx = move_toward(vx, dir * 0.50, 0.10)
	position.x += vx * (0.5+ffwd)
	if position.x <= MIN_X and vx < 0: vx = 0; dir = 0; position.x = MIN_X;
	if position.x >= HEADBUTT_X and vx > 0 and wallhp > 0:
		if vx > 0.40:
			bap()
		if wallhp > 0:
			vx = 0
			dir = 0
			position.x = HEADBUTT_X
	if position.x >= DELETE_AT_X_PAST:
		queue_free()
		deathrattle.play()
		died.emit()
	if dir < 0:
		for spr in $sprites.get_children():
			spr.setup([21,27,29,27],int(lerp(6.9,2.5,ffwd)))
	elif dir > 0:
		for spr in $sprites.get_children():
			spr.setup([21,23,25,23],int(lerp(6.9,2.5,ffwd)))
	else:
		for spr in $sprites.get_children():
			(spr as SheetSprite).playing = false # stop
	#if dir and abs(fposmod(position.x+5,10)-5) < 1:
		#var cell := maze.local_to_map(position+Vector2(2.5,2.5))
		#if maze.get_cell_tid(cell) in [10,11]:
			#maze.set_cell_tid(cell, 13)
			##await get_tree().create_timer(0.1).timeout
			#if is_instance_valid(maze):
				#maze.set_cell_tid(cell, -1)

var wallhp := 3
func bap() -> void:
	maze.set_cell_tid(Vector2i(9,9),-1)
	wallhp -= 1
	$bonk.play()
	if wallhp > 0:
		dir = 0; vx = 0;
		await get_tree().create_timer(0.1).timeout
		maze.set_cell_tid(Vector2i(9,9),99)
	else:
		$bgm_notes.stop()
		dir = 0; vx = 0;
		await get_tree().create_timer(0.1).timeout
		maze.set_cell_tid(Vector2i(9,9),99)
		await get_tree().create_timer(0.05).timeout
		maze.set_cell_tid(Vector2i(9,9),-1)
		dir = 1; vx = 0.5; # resume movement.
