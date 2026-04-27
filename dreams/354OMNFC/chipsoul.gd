extends NavdiSolePlayerBasics

enum { PEWFLASHBUF=9999515, PEWCOOLDOWNBUF=9998515, }

@onready var stage = get_parent()

var vaim : int = 0

var _evermoved : bool = false
signal firstmoved

func _ready() -> void:
	super._ready()
	bufs.setup_bufons( [
		PEWFLASHBUF,5,PEWCOOLDOWNBUF,15,
	] )

func _physics_process(_delta: float) -> void:
	if not _evermoved:
		if position.x >= 58 and vy >= 0: # must not be rising
			_evermoved = true
			firstmoved.emit()
	
	var dpad := Pin.get_dpad()
	var onflor := is_on_floor()
	
	if bufs.read(PEWFLASHBUF) <3:
		vaim = dpad.y
		var duck := onflor and vaim > 0
		if Pin.get_action_hit(): bufs.on(JUMPBUF)
		if Pin.get_offhand_hit() and not bufs.has(PEWCOOLDOWNBUF):
			# shoot!
			bufs.on(PEWFLASHBUF)
			if vaim == 0 or duck:
				# knock back horizontally
				vx -= (0.2 if duck else 0.5) * facedir # if crouching, reduced knockback
				stage.shoot(self, Vector2i(facedir,0), Vector2(0,2 if duck else 0))
			elif vaim > 0:
				if vy > 0: vy *= 0.5
				stage.shoot(self, Vector2(0,vaim), Vector2(1*facedir,0))
			else:
				if vy < 0: vy *= 0.5
				stage.shoot(self, Vector2(0,vaim), Vector2(1*facedir,0))
		tow_vx(dpad.x, 0.5 if duck else 1.0, 0.05 if onflor else 0.04)
		tow_gravity(1.0, 0.018, Pin.get_action_held(), 0.055)
		#mover.try_slip_move(self, solidcast, HORIZONTAL)
		apply_velocities()
	
	spr.frame_offset = 0
	if vaim: spr.frame_offset += 25 + 5 * vaim
	if bufs.has(PEWFLASHBUF): spr.frame_offset += 3
	
	if bufs.has(TURNBUF) and spr.frame_offset == 0:
		spr.setup([21 if onflor else 22], 0)
	elif not onflor:
		spr.setup([12],0)
	elif bufs.has(LANDBUF):
		spr.setup([11],0)
	elif dpad.x:
		spr.setup_forcechangeindex([10,11],8)
	else:
		spr.setup_trywaitformatch([10],0)
	
	if bufs.try_eat([JUMPBUF,FLORBUF]):
		vy = -1.25
