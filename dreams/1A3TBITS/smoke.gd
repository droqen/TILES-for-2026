extends Node2D

var path_point : PackedVector2Array
var target : Vector2
@onready var shapecast := $shapecast
func setup(pos : Vector2):
	position = pos
	target = Vector2(position.x, 5)
	return self
func _physics_process(_delta: float) -> void:
	var move_to_point := position
	var vel := Vector2(0,0)
	var i := 0
	for point in path_point:
		if i == 0: move_to_point = point
		match i:
			0,1,2,3:
				shapecast.target_position = point - position
				shapecast.force_shapecast_update()
				if not shapecast.is_colliding():
					move_to_point = point
		i += 1
		if i >= 4: break
	if move_to_point.y <=  5:
		move_to_point.y = -6
	if position.y < -5: queue_free()
	vel = (move_to_point - position).limit_length(0.55)
	position += vel
	$spr.position -= vel
	$spr.position *= 0.5
	#position += (move_to_point-position).limit_length(0.5)
	if vel.length_squared() < 0.0001:
		queue_free() # im stuck!
