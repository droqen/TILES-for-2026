extends Area2D

signal splatted_at(pos:Vector2,vel:Vector2)

var vy := 0.1
var splat := false

func _ready() -> void:
	area_entered.connect(func(_area): splat = true) # bye

func _physics_process(_delta: float) -> void:
	if splat:
		splatted_at.emit(position,Vector2(0,vy))
		queue_free()
	else:
		vy += 0.005
		#vy = move_toward(vy, 0.2, 0.01)
		position.y += vy
		if position.y > 95:
			position.y = 95
			queue_free()
