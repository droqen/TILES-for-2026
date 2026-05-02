extends Node2D

enum { SHOTTEDBUF, SHOTHITBUF, }

@onready var bufs : Bufs = Bufs.Make(self).setup_bufons([
	SHOTTEDBUF,12,
	SHOTHITBUF,4,
])

func _physics_process(_delta: float) -> void:
	var dpad := Pin.get_dpad()
	if Pin.get_action_hit(): bufs.on(SHOTHITBUF)
	if bufs.has(SHOTTEDBUF):
		#position += dpad as Vector2 * .5
		$spr.setup([13,14,10,10],5)
		if dpad.y < 1: dpad.y += 1
	else:
		$spr.setup_trywaitformatch([10,10,10,10,11],5)
		if Pin.get_action_held() or bufs.has(SHOTHITBUF):
			bufs.on(SHOTTEDBUF)
			get_parent().spawn_pbullet(position)
	position += dpad as Vector2
	position -= NavdiGenUtil.gen_oobdir(position, Rect2i(5+3,5+3,200-3-3,200-5-3-3)) as Vector2
