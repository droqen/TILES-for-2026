extends NavdiSolePlayerBasics

func _ready() -> void:
	super._ready()
	bufs.setup_bufons([FLORBUF, 14, ])

func _physics_process(_delta: float) -> void:
	var dpad := Pin.get_dpad()
	var wasflor := bufs.has(FLORBUF)
	var prevy := vy
	var onflor := is_on_floor()
	if onflor and not wasflor:
		print("landed @ ",position)
		if prevy < 0.3: bufs.clr(LANDBUF)
	if wasflor and not onflor: vy = -0.07
	var plant := onflor and Pin.get_plant_held()
	var ffall := not onflor and dpad.y > 0
	if plant: dpad.x = 0
	if Pin.get_jump_hit(): bufs.on(JUMPBUF)
	if onflor and (dpad.x*vx<=0 or abs(vx)<0.6):
		tow_vx(dpad.x, 1.2, 0.10)
	else:
		tow_vx(dpad.x, 1.2, 0.02)
	if ffall and vy < 0: vy += .200
	if ffall: tow_gravity(1.5, .040)
	else: tow_gravity(1.2, .010, Pin.get_jump_held(), .040)
	apply_velocities()
	# spr
	if bufs.has(TURNBUF):
		spr.setup([28],0)
	elif not onflor:
		if ffall: spr.setup([19,29],int(remap(vy,1.5,-1.0,3,12)))
		elif vy < -.1:
			spr.setup([12],0)
		elif vy > 0.1:
			spr.setup([13],0)
			
	elif bufs.has(LANDBUF):
		spr.setup([14],0)
	elif plant:
		spr.setup([18,18,18,15,16,17,18,18,],20)
	elif dpad.x:
		spr.setup_forcechangeindex([11,10],12)
	else:
		spr.setup_trywaitformatch([10],0)
	
	if bufs.try_eat([JUMPBUF,FLORBUF]):
		vy = -1.02
