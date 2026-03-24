extends Node2D

@onready var vessel : NavdiVessel = $"../NavdiVessel"
@onready var maze : Maze = $Maze
@onready var player = $pair
var room : Vector2i = Vector2i(0,0)
@warning_ignore("integer_division")
@onready var ROOMSIZE : Vector2i = vessel.vessel_room_size / 10

var raven_leaves_room_4_threshold : int = 0

func loadroom() -> void:
	maze.copy_from(
		vessel.get_maze(),
		Rect2i(room * ROOMSIZE, ROOMSIZE),
		Vector2i(0,0),
		true,
	)
	vessel.spawn_exiles_by_roomcoords(room, $Exiles)
	
	$BgExit.hide()
	raven_leaves_room_4_threshold = 0
	if room.x == 4:
		if not Dreamer.r("raven_left"):
			raven_leaves_room_4_threshold = randi_range(50, 150) + randi_range(-20,40)
	if room.x == 5:
		Dreamer.w("raven_left", true)
		$BgExit.show()

func _ready() -> void:
	if randf() < 0.1: Dreamer.w("raven_left", true)
	loadroom.call_deferred()

var cars_driving := true

func _physics_process(_delta: float) -> void:
	if randf() < 0.05:
		$cars_driving_by.tempo = randi_range(100,200)
	if randf() < 0.01:
		cars_driving = not cars_driving
		if cars_driving:
			$cars_driving_by.play()
		else:
			$cars_driving_by.stop()
	if is_instance_valid(player):
		if room.x == 4 and raven_leaves_room_4_threshold and player.position.x > raven_leaves_room_4_threshold:
			Dreamer.w("raven_left", true)
			raven_leaves_room_4_threshold = 0
		var traveldir = NavdiGenUtil.gen_oobdir(player.position, Rect2i(Vector2i(0,0),ROOMSIZE*10), 5)
		if room.x >= 5 and traveldir.x > 0:
			traveldir.x = 0
			player.queue_free() # bye
		if room.x <= 0 and traveldir.x < 0:
			traveldir.x = 0
		if traveldir:
			room.x += traveldir.x
			player.position.x -= traveldir.x * (ROOMSIZE.x*10 - 10)
			loadroom()
