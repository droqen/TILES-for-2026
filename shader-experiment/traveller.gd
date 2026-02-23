extends Sprite2D

var velocity : Vector2

func _physics_process(_delta: float) -> void:
	velocity.x = move_toward(velocity.x, Pin.get_dpad().x, 0.1)
	velocity.y = move_toward(velocity.y, Pin.get_dpad().y, 0.1)
	position += velocity
