extends NavdiSolePlayerBasics

var bonk : int = 0

func _physics_process(_delta: float) -> void:
	
	$lo_noise.volume = remap(position.y,-65,65,0.15,0.0)
	$mid_noise.volume = 0.05
	$hi_noise.volume = remap(position.y,65,-65,0.0,0.15)
	
	if bonk > 0: bonk -= 1
	
	var dpad := Pin.get_dpad()
	if bonk:
		dpad.y = -1
		if vy > 0: vy = 0
		if dpad.x > -1: dpad.x -= 1
	#vx = lerp(vx, -position.x*0.1,0.01)
	#vy = lerp(vy, -position.y*0.1,0.01)
	var tomiddle : Vector2 = -position
	var tomiddledir = tomiddle.normalized()
	var tomiddlelen = tomiddle.length()
	if tomiddledir:
		tomiddle = tomiddledir * (40 + tomiddlelen*0.5)
	vx *= 0.99; vx += tomiddle.x * 0.0005
	vy *= 0.99; vy += tomiddle.y * 0.0009
	tow_vx(dpad.x, 1.0, .04, false)
	vy = move_toward(vy, dpad.y, .04)
	apply_velocities()
	
	if bonk:
		spr.visible = bonk % 6 < 2
	else:
		spr.show()
	
	if bufs.has(TURNBUF):
		spr.setup([15])
	elif dpad.y > 0:
		spr.setup([13,14],5)
	elif dpad.y < 0:
		spr.setup([12])
	else:
		spr.setup([10,11],10)

func _on_exit_toucher_area_entered(area: Area2D) -> void:
	if area.get_parent().name == "ExitSpr":
		queue_free()
	else:
		bonk = randi_range(31,49)
