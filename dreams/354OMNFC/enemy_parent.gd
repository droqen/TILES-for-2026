extends Node2D

var stage = null
var targetplayer : Node2D = null

func setup(pos,_stage,_targetplayer):
	position = pos
	stage = _stage
	targetplayer = _targetplayer
	return self

@onready var hitbox : Area2D = $hitbox
@onready var hurtbox : Area2D = $hurtbox
func check_boxes() -> void:
	for hitarea in hitbox.get_overlapping_areas():
		var bullet = hitarea.get_parent()
		if not bullet.struck_target:
			on_hit_by(bullet)
			bullet.struck_target = true
		#on_hit_by(hitarea.get_parent())
	for hurtarea in hurtbox.get_overlapping_areas():
		exec_hurt(hurtarea.get_parent())

func on_hit_by(bullet : Node2D) -> void:
	position += bullet.vel * 5

func exec_hurt(target : Node2D) -> void:
	print("i hurt target ",target)

func _physics_process(_delta: float) -> void:
	check_boxes() # should override
