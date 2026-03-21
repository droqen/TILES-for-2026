extends NavdiSolePlayerBasics

@export var target : Node2D
@onready var viewrect : Rect2i = $"../View".get_rect() as Rect2i
func _physics_process(_delta: float) -> void:
	var dpad = Pin.get_dpad()
	
	var offedge_off = NavdiGenUtil.gen_oobdir(position, viewrect, -2)
	if offedge_off.x: position.x -= offedge_off.x; vx = 0
	if offedge_off.y: position.y -= offedge_off.y; vy = 0
	var offedge_near = NavdiGenUtil.gen_oobdir(position, viewrect, 2)
	if dpad.x == 0: dpad.x = -offedge_near.x
	if dpad.y == 0: dpad.y = -offedge_near.y
	
	vx *= 0.99; tow_vx(dpad.x, 0.5, 0.01);
	vy += 0.01; vy = move_toward(vy, dpad.y * 0.5, 0.015)
	apply_velocities()
	if max(abs(position.x-target.position.x),
			abs(position.y-target.position.y)) < 4:
				queue_free()
	if dpad.y < 0:
		spr.setup([10,11,11,21,11,11,10],3)
	elif bufs.has(TURNBUF):
		spr.setup([12])
	elif dpad.y > 0:
		if dpad.x == 0: spr.setup([10])
		else: spr.setup([20])
	else:
		spr.setup([10,11],20)
