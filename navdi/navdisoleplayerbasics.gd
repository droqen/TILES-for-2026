extends NavdiSolePlayer
class_name NavdiSolePlayerBasics

var spr : SheetSprite
var mover : NavdiBodyMover
var solidcast : ShapeCast2D
var vx : float 
var vy : float 
var _faceleft : bool
var faceleft : bool :
	get    : return _faceleft
	set(v) : if _faceleft != v:
		_faceleft = v
		bufs.on(TURNBUF)
		spr.flip_h = _faceleft
var facedir : int :
	get    : return -1 if faceleft else 1
	set(v) : if v : faceleft = v < 0
@onready var bufs : Bufs = Bufs.Make(self).setup_bufons([FLORBUF,4,JUMPBUF,4,TURNBUF,4,])

enum { FLORBUF=7102837, JUMPBUF=7339837, TURNBUF=7325837, }

func setup_basic_child_nodes(
	SheetSpriteNodePath : String = "spr",
	MoverNodePath : String = "mover",
	ShapeCastNodePath : String = "mover/solidcast"
) -> NavdiSolePlayerBasics:
	self.spr = get_node(SheetSpriteNodePath)
	self.mover = get_node(MoverNodePath)
	self.solidcast = get_node(ShapeCastNodePath)
	return self

func _ready() -> void:
	push_error("Hey you should override _ready; call setup_basic_child_nodes() manually")
	setup_basic_child_nodes(
		#"spr","mover","mover/solidcast"
	)

func tow_vx(
	dir:int,
	target_speed:float,
	accel:float
) -> void:
	vx = move_toward(vx,dir*target_speed,accel)

func tow_gravity(
	max_fall_velocity:float,
	grav_normal:float,
	input_slow_fall:bool = false,
	grav_extra:float = 0.0) -> void:
	vy = move_toward(vy, max_fall_velocity,
		(grav_normal + grav_extra)
			if (vy<0 and !input_slow_fall)
				else grav_normal)

func is_on_floor() -> bool:
	var on_floor : bool = false
	if vy >= 0 and mover.cast_fraction(self, solidcast, VERTICAL, 1) < 1:
		on_floor = true
		bufs.on(FLORBUF)
	return on_floor

func apply_velocities() -> void:
	if!mover.try_slip_move(self,solidcast,HORIZONTAL,vx):
		vx=0
	if!mover.try_slip_move(self,solidcast,VERTICAL,vy):
		vy=0
