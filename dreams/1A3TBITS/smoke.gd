extends Node2D

var path_point : PackedVector2Array
var target : Vector2
var cell_from_above : Vector2i
var cell_center_from_above : Vector2
var target_cell_center : Variant
var stillmovementdelay : int
var smokedensities_from_above : Dictionary[Vector2i,int]
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
		if target_cell_center == null:
			if stillmovementdelay > 0:
				stillmovementdelay -= 1
			else:
				stillmovementdelay = randi_range(20,40)
				# im stuck, so lets just wander around
				var c := cell_from_above
				var bestdir = null
				var bestdirs_density = 99
				#var alldirs = [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN,]
				var alldirs = [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.DOWN,]
				alldirs.shuffle()
				alldirs.push_front(Vector2i.UP)
				for dir in alldirs:
					shapecast.target_position = dir as Vector2 * 5 + cell_center_from_above - position
					shapecast.force_shapecast_update()
					if not shapecast.is_colliding():
						var density = smokedensities_from_above.get(c+dir, 0)
						if density < bestdirs_density:
							bestdir = dir
							bestdirs_density = density
				if bestdir != null:
					target_cell_center = cell_center_from_above + (bestdir as Vector2) * 10
				else:
					queue_free() # bye
		else:
			var to_target : Vector2 = (target_cell_center - position)
			if to_target.length_squared() < 0.25:
				position += to_target
				target_cell_center = null
			else:
				position += to_target.limit_length(0.5)
			
	else:
		target_cell_center = null
		stillmovementdelay = 0
