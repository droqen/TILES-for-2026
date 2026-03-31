extends Node2D

var velocity : Vector2
@onready var frez := randi_range(3,5)
@onready var life := randi_range(5,30)
func _physics_process(_delta: float) -> void:
	if frez > 0:
		frez -= 1
	else:
		position += velocity
		velocity.y += 0.05
		if position.x < 0: position.x = 0; queue_free()
		if position.x > 95: position.x = 95; queue_free()
		if position.y > 95: position.y = 95; queue_free()
		if life > 0: life -= 1
		else: queue_free()
