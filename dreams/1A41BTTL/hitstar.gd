extends Sprite2D

var velocity : Vector2
var age : int

func setup(center:Vector2,quad:int):
	var dx : int = [0,1,0,1][quad]
	var dy : int = [0,0,1,1][quad]
	position = center + 5 * Vector2(dx-1,dy-1)
	age = randi_range(0,5)
	velocity = Vector2(dx-0.5,dy-0.5)
	return self
func _physics_process(_delta: float) -> void:
	age += 1
	position += velocity * randf()
	velocity.y += 0.2 * randf()
	if age > 15: queue_free() # bye
