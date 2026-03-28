extends NavdiSolePlayerBasics

enum {RESPAWNBUF}
var _sitting : bool = false
var sitting : bool :
	get : return _sitting
	set (v) : if _sitting != v:
		_sitting = v
		if v: $sfx_sit.play()
		else: $sfx_sit.stop()

@onready var startpos := position
@onready var hitbox : Area2D = $hitbox

func _ready() -> void:
	super._ready()
	bufs.setup_bufons([RESPAWNBUF, 32, ])
	faceleft = true;
	hitbox.area_entered.connect(_on_hurtbox_entered)
func _physics_process(_delta: float) -> void:
	if position.x <= -2: queue_free(); return;
	if position.x > 223: position.x = 223
	if position.y > 170:
		bufs.on(RESPAWNBUF)
		position = startpos
		vx = 0
		vy = 0
		faceleft = true
		spr.setup([10])
	var dpad := Pin.get_dpad()
	var onfloor := is_on_floor()
	if sitting: dpad.x = 0
	if bufs.has(RESPAWNBUF):
		dpad.x = 0
		visible = bufs.read(RESPAWNBUF)%4>=2
	else:
		show()
		if Pin.get_jump_hit(): bufs.on(JUMPBUF)
		if onfloor and Pin.get_plant_hit() and not bufs.has(RESPAWNBUF):
			sitting = true
			$sfx_sit.play(0.4)
	tow_vx(dpad.x, 0.6666, 0.1)
	tow_gravity(1.0, 0.06, Pin.get_jump_held(), 0.04)
	apply_velocities()
	if !onfloor:
		spr.setup([11])
		sitting = false
	elif bufs.has(TURNBUF):
		spr.setup([51])
	elif sitting:
		if spr.frame == 50: spr.setup([50])
		else: spr.setup([41,50],10)
	elif dpad.x:
		spr.setup_forcechangeindex([11,21,31,41],10)
	else:
		spr.setup_trywaitformatch([10,10,10,10,20,30,30,30,40,],20,[21,41])
	if bufs.try_eat([JUMPBUF,FLORBUF]):
		vy = -1.0
		sitting = false
func _on_hurtbox_entered(hurtbox : Area2D) -> void:
	var knife = hurtbox.get_parent()
	knife.struck()
	bufs.setmin(RESPAWNBUF,10)
	vy = -1.0
	facedir = sign(175-position.x)
	$sfx_ouch.play()
