extends Node2D

var vel : Vector2
var deathanim : int = 0
var struck_target : bool = false

func setup(_pos:Vector2, _dir:Vector2i):
	vel = Vector2(_dir) * 1
	position = _pos + vel * 5
	$spr.rotation = vel.angle()
	#$mover/solidcast.rotation = vel.angle()
	$mover.position += vel * 2
	#$spr.region_offset = Rect2i(0,4,10,2)
	#$spr.setup([0],0)
	#if vel.x < 0: $spr.flip_h = true
	return self

func _physics_process(_delta: float) -> void:
	if deathanim > 0:
		$spr.setup([17],0)
		struck_target = true
		deathanim += 1
		if deathanim > 5: queue_free()
	else:
		if struck_target:
			deathanim = 1
		if vel.x:
			if not $mover.try_move(self, $mover/solidcast, HORIZONTAL, vel.x * 2):
				deathanim = 1
		if vel.y:
			if not $mover.try_move(self, $mover/solidcast, VERTICAL, vel.y * 2):
				deathanim = 1
		if $wallhitter.get_overlapping_bodies():
			deathanim = 1
