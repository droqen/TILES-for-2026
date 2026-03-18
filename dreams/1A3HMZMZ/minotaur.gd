extends NavdiSolePlayerBasics

func _physics_process(_delta: float) -> void:
	var dpad := Pin.get_dpad()
	tow_vx(dpad.x, 1, 10)
	vy = dpad.y
	#apply_velocities()
	var prevposx := position.x
	if!mover.try_slip_move(self,solidcast,VERTICAL,vy):
		vy=0
	if position.x==prevposx: # if y did not slip, then do x
		if!mover.try_slip_move(self,solidcast,HORIZONTAL,vx):
			vx=0
	if dpad:
		spr.setup_forcechangeindex([10,11],10)
	else:
		spr.setup_trywaitformatch([10])
	
