extends Node2D

@onready var startpos = position

var leaving := false
var chaargebuf := 0
var springbuf := 0
var ouchiebuf := 0
var wishingbuf := 0
var dodgingbuf := 0
var dodgedir : Vector2

func q_leave() -> void:
	leaving = true

func q_wish() -> void:
	wishingbuf = 3

func q_dodge() -> void:
	if dodgingbuf <3:
		dodgedir = Vector2(5, 5).rotated(randf_range(-1,1))
	dodgingbuf = 5
	spring_to_target(startpos + dodgedir, 1.0)

func spring_to_target(target : Vector2, fraction : float = 0.9):
	var realtarget = lerp(startpos,target,fraction)
	position = lerp(position, realtarget,0.4)
	springbuf = 10

func _physics_process(_delta: float) -> void:
	if leaving:
		position.x += 0.33
		$spr.setup([25,26],10)
		if position.x > 145: queue_free()
		return
	
	if ouchiebuf > 0:
		ouchiebuf -= 1
		if ouchiebuf < 5:
			$spr.setup([19])
		else:
			$spr.setup([19,29],3)
	elif chaargebuf > 0:
		chaargebuf -= 1
		$spr.setup([16,16,17,16,16,18,],2)
	elif wishingbuf > 0:
		wishingbuf -= 1
		$spr.setup([24])
	elif dodgingbuf > 0:
		dodgingbuf -= 1
		$spr.setup([28])
	else:
		$spr.setup([14,15],30)
	if springbuf > 0:
		springbuf -= 1
	else:
		position = lerp(position,startpos,0.2)

func play_ouchie() -> void:
	ouchiebuf = 10
