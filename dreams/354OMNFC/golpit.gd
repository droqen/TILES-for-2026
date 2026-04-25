extends EnemyParent
const EnemyParent = preload("res://dreams/354OMNFC/enemy_parent.gd")

var vel : Vector2

func _physics_process(_delta: float) -> void:
	check_boxes()
	if is_instance_valid(targetplayer):
		vel = lerp(vel, (targetplayer.position as Vector2 - position).limit_length(1.0), 0.02)
	else:
		vel *= 0.98
	position += vel

func on_hit_by(bullet) -> void:
	if bullet.vel.x:
		vel.x = 1.0 * sign(bullet.vel.x)
	if bullet.vel.y:
		vel.y = 1.0 * sign(bullet.vel.y)
