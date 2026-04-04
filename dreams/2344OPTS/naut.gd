extends Node2D

@onready var spr : SheetSprite = $Spr

func try_reach(target:Vector2, maxchange:float) -> bool:
	var towed := false
	if abs(target.x-position.x) > maxchange:
		position.x = move_toward(position.x, target.x, maxchange)
		towed = true
	else:
		position.x=target.x
	if abs(target.y-position.y) > maxchange:
		position.y = move_toward(position.y, target.y, maxchange)
		towed = true
	else:
		position.y=target.y
	return not towed

func loop_walk_to(target : Vector2) -> void:
	if target.x != position.x: spr.flip_h = target.x < position.x
	for i in range(50):
		if try_reach(target, 0.5):
			spr.setup([10]); break;
		else:
			spr.setup([11,10,11],7)
			await get_tree().physics_frame
	spr.setup([10])

func loop_climb_to(target : Vector2) -> void:
	for i in range(50):
		if try_reach(target, 0.5):
			break
		else:
			spr.setup([20,21],10)
			await get_tree().physics_frame
	spr.setup([spr.frame])

func loop_fall_to(target : Vector2) -> void:
	position.x = target.x
	var vy : float = 0.0
	for i in range(100):
		if try_reach(target, vy):
			spr.setup([32]); await get_tree().create_timer(0.25).timeout
			break
		else:
			spr.setup([30,31],5)
			vy += 0.1
			await get_tree().physics_frame
	spr.setup([10]) # done
