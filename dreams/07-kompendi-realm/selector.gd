extends Node2D

@onready var maze : Maze = $"../Maze"
@onready var flashlayer : Maze = $"../FlashLayer"
var target_cell : Vector2i = Vector2i(4,4)
var dtap_queued : Vector2i
var charged : bool = false
var stillness : int = 0
var stunned : int = 0

var cascading : bool = false
var to_next_cascade : int

func _ready() -> void:
	to_next_cascade = randi_range(200,999)

func _physics_process(_delta: float) -> void:
	var dpad = Pin.get_dpad()
	var dtap = Pin.get_dpad_tap()
	if dtap.x: dtap.y = 0
	if dtap: dtap_queued = dtap
	if dtap_queued.x and dpad.x: dpad.y = 0
	if dtap_queued.y and dpad.y: dpad.x = 0
	if dpad.x: dpad.y = 0
	
	if cascading:
		stunned = 3
	
	if stunned > 0:
		stunned -= 1
		$Spr.ani_subindex = 0 # frozen
		dpad *= 0
		dtap *= 0
		dtap_queued *= 0
		if stunned <= 0 and not cascading:
			if (not can_i_go_that_way(Vector2i.RIGHT)
			and not can_i_go_that_way(Vector2i.DOWN)
			and not can_i_go_that_way(Vector2i.LEFT)
			and not can_i_go_that_way(Vector2i.UP)):
				pinglow = 5.0
				play_a_ping()
				play_a_ping()
				play_a_ping()
				play_a_ping()
				charged = false
				if to_next_cascade < 50: to_next_cascade = 50
	else:
		pinglow = lerp(pinglow,1.0,0.01)
		if to_next_cascade > 0: to_next_cascade -= 1
	
	var target_pos = maze.map_to_local(target_cell) + Vector2(5,5)
	var to_target = target_pos - position
	if to_target:
		position += to_target.limit_length(0.5)
		if to_target.x < 0 and dpad.x > 0: target_cell.x += 1
		if to_target.y < 0 and dpad.y > 0: target_cell.y += 1
		if to_target.x > 0 and dpad.x < 0: target_cell.x -= 1
		if to_target.y > 0 and dpad.y < 0: target_cell.y -= 1
		if position.x <  5: target_cell.x = 0
		if position.y <  5: target_cell.y = 0
		if position.x >= 95: target_cell.x = 8
		if position.y >= 95: target_cell.y = 8
	if target_pos == position:
		if stunned > 0:
			pass # charged = false
		elif to_next_cascade <= 0:
			cascade()
		else:
			if not dpad:
				if dtap_queued.x and not to_target.x: dpad.x = dtap_queued.x
				if dtap_queued.y and not to_target.y: dpad.y = dtap_queued.y
			dtap_queued = Vector2i.ZERO
			if dpad:
				stillness = 0
				if can_i_go_that_way(dpad):
					target_cell += dpad
			elif charged:
				stillness += 1
				if stillness > 4:
					charged = false
					scramble()
	else:
		charged = true
		stillness = 0

func cascade() -> void:
	cascading = true
	to_next_cascade = randi_range(200,999)
	for y in range(10):
		for x in range(10):
			if randf() < 0.25:
				stunned = 10
				charged = false
				mix(Vector2i(x,y))
				await get_tree().create_timer(randf_range(0.02,0.05)).timeout
	stunned = 3
	cascading = false

func flash(cell:Vector2i) -> void:
	flashlayer.set_cell_tid(cell,3)
	await get_tree().create_timer(randf_range(0.10,0.15)).timeout
	if not is_instance_valid(flashlayer): return
	flashlayer.set_cell_tid(cell,-1)

func here() -> Vector2i:
	return maze.local_to_map(position-Vector2(5,5))

func scramble() -> void:
	var h : Vector2i = here()
	for x in range(2): for y in range(2):
		mix(h + Vector2i(x,y))

func mix(t:Vector2i, forced_result:int=-1) -> void:
	flash(t)
	if forced_result >= 0:
		maze.set_cell_tid(t, forced_result)
	else:
		maze.set_cell_tid(t, randi() % 3)
	stunned = 3
	play_a_ping()

var pingdex : int = 0
var pinglow : float = 1.0

func play_a_ping() -> void:
	play_ping($pings.get_child(pingdex))
	pingdex = (pingdex + 1) % 4

func play_ping(ping:AudioStreamPlayer) -> void:
	await get_tree().create_timer(randf()*0.01).timeout
	ping.pitch_scale = randf_range(0.9,1.1) / pinglow
	ping.play()
	pinglow += 0.01

func can_i_go_that_way(dir:Vector2i) -> bool:
	var a:Vector2i = here(); var b:Vector2i = here();
	match [dir.x,dir.y]:
		[ 1, 0]: a.x+=1; b.x+=1; b.y+=1;
		[ 0, 1]: a.y+=1; b.y+=1; b.x+=1;
		[-1, 0]: b.y+=1;
		[ 0,-1]: b.x+=1;
#             a   a   a
#           
#             a   0   a
#                   x
#             a   a   a
	return maze.get_cell_tid(a) != maze.get_cell_tid(b)
