extends Node2D

@onready var maze : Maze = $Maze
@onready var vessel : NavdiVessel = $"../NavdiVessel"
@onready var msgappear : NavdiBeep = $msgappear
@onready var msgbkspc : NavdiBeep = $msgbkspc
@onready var player = $rover
var bkspcplaying : bool = false
var player_respawn_left : bool = false
var roomcoords : Vector2i = Vector2i(0,0)
var npc_rovers : Array = []
func _ready() -> void:
	loadroom.call_deferred()
func loadroom() -> void:
	@warning_ignore("integer_division")
	maze.copy_from(
		vessel.get_maze(),
		Rect2i(
			roomcoords * vessel.vessel_room_size/10,
			vessel.vessel_room_size/10
		)
	)
	vessel.spawn_exiles_by_roomcoords(roomcoords, $Objects, true)
	npc_rovers = $Objects.get_children().filter(func(n):return n.get('IS_ROVER'))
	bkspcplaying = false; #msgbkspc.stop()
	for npc in npc_rovers:
		npc.opened.connect(func(): msgappear.play())
		npc.hidestarted.connect(func(): bkspcplaying = true)
		npc.hidestopped.connect(func(): bkspcplaying = false)#; msgbkspc.stop())
func _physics_process(_delta: float) -> void:
	if bkspcplaying:
		msgbkspc.stop()
		msgbkspc.play()
	if is_instance_valid(player):
		var liftoff := false
		var playercell := maze.local_to_map(player.position)
		if playercell.x <= 10 and playercell.y <= 3:
			player_respawn_left = true
		if playercell.x >= 18 and playercell.y <= 3:
			player_respawn_left = false
		if playercell.y < 0 and roomcoords.y <= 0: playercell.y = 0
		if maze.get_cell_tid(playercell)==99:
			liftoff = true
		if liftoff:
			if player.vy < -0.50:
				player.vy = 0
			player.vy = lerp(player.vy, -0.50, 0.15)
			player.vx *= 0.8
		var traveldir := NavdiGenUtil.gen_oobdir(player.position,
		Rect2i(Vector2(0,0),vessel.vessel_room_size),
		1)
		if traveldir.y < 0:
			traveldir.y = 0 # no travelling above 0
			if player.position.y < -4.5:
				player.queue_free()
				for cell in maze.get_used_cells_by_tids([99]):
					maze.set_cell_tid(cell, [20,20,20,20,21,22,23][randi()%7])
		if traveldir.y > 0:
			traveldir.y = 0 # no travelling below 0 on screen x=-1
			if player.position.y > 110:
				if roomcoords.x == -1:
					if player_respawn_left:
						player.position = maze.map_to_local(Vector2i(10,2))
					else:
						player.position = maze.map_to_local(Vector2i(18,3))
				elif roomcoords.x == -2:
						player.position = maze.map_to_local(Vector2i(20,7))
				player.position.y += 1
				player.vx = 0
				player.vy = 0.5
				player.flashing = 25
		if traveldir.x:
			roomcoords += traveldir
			player.position.x -= traveldir.x * (vessel.vessel_room_size.x-2)
			loadroom()
