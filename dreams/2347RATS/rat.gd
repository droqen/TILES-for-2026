extends NavdiSolePlayerBasics

enum {APPEARBUF}

var dead : bool = false
var exited : bool = false
var onfloor : bool = false
var force_highest_jump : bool = false
var force_dpadx : int = 0

func _ready() -> void:
	if NavdiSolePlayer.GetPlayer(self) == null:
		super._ready()
	else:
		super.setup_basic_child_nodes()
	bufs.setup_bufons([APPEARBUF,5])

func _physics_process(_delta: float) -> void:
	onfloor = is_on_floor()
	
	if dead or exited:
		if exited: hide() # im gawn
		elif dead:
			show();
			if randf() < 0.04: spr.setup([15],0)
			elif randf() < 0.02: spr.setup([16],0)
			else: spr.setup([13],0);
			vy += 0.01 * randf()
			if vy + randf()*0.1 > 0.1: vy = 0.0
			mover.try_slip_move(self,solidcast,VERTICAL,vy)
		return
	else: show()
	
	var dpad := Pin.get_dpad()
	if dpad.x == 0 and force_dpadx:
		dpad.x = force_dpadx
	tow_vx(dpad.x, 0.75, 0.15)
	tow_gravity(1.4, 0.04, Pin.get_jump_held() or force_highest_jump, 0.05)
	apply_velocities()
	if Pin.get_jump_hit(): bufs.on(JUMPBUF)
	
	if bufs.has(APPEARBUF):
		spr.setup([20],0)
	elif !onfloor:
		spr.setup([14],0)
	elif dpad.x:
		spr.setup_forcechangeindex([10,12,11,12,],8)
	else:
		if dpad.y > 0: # duck
			spr.setup_trywaitformatch([12],0)
		else:
			spr.setup_trywaitformatch([10],0,[10,11])
	
	if bufs.try_eat([JUMPBUF,FLORBUF]):
		vy = -1.3; onfloor = false;

func copy_rat(rat) -> void:
	position = rat.position
	vx = rat.vx
	vy = rat.vy
	spr.setup(rat.spr.frames, rat.spr.ani_period)
	faceleft = rat.faceleft
	dead = rat.dead
	exited = rat.exited
	onfloor = rat.onfloor
	#for BUFKEY in [FLORBUF,JUMPBUF,LANDBUF]:
		#bufs.bufdic[BUFKEY] = rat.bufs.bufdic[BUFKEY]
