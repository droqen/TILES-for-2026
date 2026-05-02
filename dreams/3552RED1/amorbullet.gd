extends Node2D

var vx : float
var struck : bool
var poststruckfade : int
var stage

func setup(_stage,player, index : int) -> void:
	stage = _stage
	vx = 1.0 * player.facedir
	$spr.flip_h = player.faceleft
	match index:
		0: position = player.position + Vector2(vx,-2.5)
		1: position = player.position + Vector2(-vx,1.5)

func _physics_process(_delta: float) -> void:
	if struck:
		poststruckfade += 1
		$spr.setup([15],0)
		if poststruckfade > 3: queue_free()
	else:
		var hit_wall : bool = not ($mover
		.try_move(self, $mover/solidcast, HORIZONTAL, vx)
		)
		for area in $hurtbox.get_overlapping_areas():
			var target = area.get_parent()
			if target.has_method("try_hitby"): # check if it's hittable
				if target.try_hitby(self):
					try_strike()
		if hit_wall and not struck: try_strike()
		# get outside world
	
func try_strike() -> bool:
	if not struck:
		struck = true
		poststruckfade = 0
		return true
	else: return false
