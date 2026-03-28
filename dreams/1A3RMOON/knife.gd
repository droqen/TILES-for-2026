extends Node2D

@export var velocity : Vector2

var deadtimer := 0
var diesound : NavdiBeep = null

func _ready() -> void:
	$spr.ani_period = randi_range(4,7)
	$spr.ani_subindex = randi() % 10

func _physics_process(_delta: float) -> void:
	if deadtimer > 0:
		deadtimer += 1
		#visible = deadtimer % 5 < 2
		if deadtimer > 6: queue_free()
	else:
		position += velocity
		if position.x > 226 or position.y > 136:
			queue_free()
		elif position.y > randi_range(105,110):
			struck()
			if diesound: diesound.play()
	
func struck() -> void:
	$hurtbox.queue_free()
	deadtimer = 1
