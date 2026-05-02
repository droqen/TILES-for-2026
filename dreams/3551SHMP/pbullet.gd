extends Node2D

var dead = false
var deadanim : int = 0

func _ready() -> void:
	$spr.scale *= 2
	$hurtbox.connect("area_entered", func(enemy_hitbox):
		if not dead:
			var enemy = enemy_hitbox.get_parent()
			enemy.owie()
			$hurtbox.queue_free()
			dead = true
	)

func _physics_process(_delta: float) -> void:
	if dead:
		$spr.scale *= 1.3
		deadanim += 1
		if deadanim >= 2: queue_free()
	else:
		$spr.scale = lerp($spr.scale, Vector2(1,1), 0.3)
		position.y -= 2
		if position.y < -2: queue_free()
