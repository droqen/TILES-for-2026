extends Node2D

@onready var spr : SheetSprite = $spr
@onready var mover = $mover
@onready var solidcast = $mover/solidcast
@onready var maze : Maze = $"../Maze"
enum {TURNBUF}
@onready var bufs : Bufs = Bufs.Make(self).setup_bufons([TURNBUF, 8])

var frm_ground : int = 41
const FRMS_AWAKE_SEQ : Array[int] = [00, 54, 55, 56, 57]
const FRMS_STAND : Array[int] = [50,51]
const FRMS_WALK : Array[int] = [52,51,53,51]
const FRMS_TURN : Array[int] = [60]

var wakeness : float = 0.0
var wakestep : int = 0
var awake : bool = false
const LAST_WAKE_STEP : int = len(FRMS_AWAKE_SEQ) - 1

var faceleft : bool :
	get: return faceleft
	set(v): faceleft = v; bufs.on(TURNBUF); spr.flip_h = faceleft; spr.setup(FRMS_TURN);

func _ready() -> void:
	spr.setup([FRMS_AWAKE_SEQ[1]])

func _physics_process(_delta: float) -> void:
	if awake:
		spr.setup(FRMS_WALK)
		position.x += -1 if faceleft else 1
	elif wakestep < LAST_WAKE_STEP:
		wakeness += 0.2 * randf()
		if randf() < 0.1: wakeness = 0
		if wakeness >= 1:
			wakeness = 0
			wakestep += 1
		else:
			var f : int = FRMS_AWAKE_SEQ[wakestep+int(wakeness*2)]
			if f == 00: f = frm_ground
			spr.setup([f])
	else:
		awake = true
		faceleft = randf() < 0.5
