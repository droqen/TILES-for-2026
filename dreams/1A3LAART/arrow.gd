extends Node2D

var phase : int = 0
var sprframe : int = randi() % 8
var xmoved : int = 0
func _physics_process(_delta: float) -> void:
	xmoved = 0
	if phase <3:
		phase += 3
	else:
		phase = 0
		sprframe = (sprframe+1)%8
		position.x -= 1
		xmoved -= 1
		if sprframe == 0: phase -= 20;
	$spr.setup([20+posmod(-sprframe,8)])
