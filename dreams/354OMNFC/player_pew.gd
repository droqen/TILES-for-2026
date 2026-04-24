extends Node2D

var vel : Vector2

func setup(_pos:Vector2, _dir:Vector2i):
	vel = Vector2(_dir) * 1
	position = _pos + vel * 5
	$spr.rotation = vel.angle()
	#$mover/solidcast.rotation = vel.angle()
	$mover.position += vel * 2
	#$spr.region_offset = Rect2i(0,4,10,2)
	#$spr.setup([0],0)
	if vel.x < 0: $spr.flip_h = true
	return self

func _physics_process(_delta: float) -> void:
	if vel.x:
		if not $mover.try_move(self, $mover/solidcast, HORIZONTAL, vel.x * 2):
			queue_free()
	if vel.y:
		if not $mover.try_move(self, $mover/solidcast, VERTICAL, vel.y * 2):
			queue_free()
	if $mover/hitter.get_overlapping_bodies():
		queue_free() # also bye
