extends Node2D

var vx : float = 0.3
var pause : int = 0

func _ready() -> void:
	respawn()
func _physics_process(_delta: float) -> void:
	if pause > 0:
		pause -= 1
	else:
		position.x -= 8*(randf() * vx)
		position.y -= 8*(randf())
		if position.y < -85: respawn()
func respawn() -> void:
	if randf () < 0.5: pause = randi_range(0,100)
	vx = randf_range(0.2,0.4)
	position = Vector2(randf_range(-73,114), randf_range(97,153))
	$spr.ani_index = randi() % 4
	$spr.ani_period = randi_range(3,5)
