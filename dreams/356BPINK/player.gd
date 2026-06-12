extends Node2D

var vx : float = 0.0

func _physics_process(_delta: float) -> void:
	var dpad := Pin.get_dpad()
	vx = move_toward(vx, dpad.x * 0.5, 0.01)
	$Spr.ani_period = int(lerp(40,10,2*abs(vx)))
	position.x += vx
	if position.x > 249: position.x = 249; vx = 0
	if position.x < 86: queue_free(); $"../Maze".set_cell_tid(Vector2i(8,5),1)
