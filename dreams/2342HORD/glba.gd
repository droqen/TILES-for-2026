extends Node2D

var startpos : Vector2
var ang : float
var angvel : float
var hinge : Vector2
var normal_aniperiod : int
var ouchiebuf := 0
var springbuf := 0
var revivebuf := 0

func setup(_startpos: Vector2, _letter:String, _aniperiod:int):
	self.startpos = _startpos
	self.name = "GLB"+_letter
	$nmLabel.text = "glb"+_letter
	$spr.ani_period = _aniperiod ;normal_aniperiod = _aniperiod
	
	ang = randf()*PI
	angvel = randf_range(0.011,0.012)
	hinge = Vector2(randf_range(2,3.5),0)
	self.position = startpos + hinge.rotated(ang)
	
	return self

func q_revive() -> void:
	$spr.setup([40,41,42,43,10,11,12,13],5)
	show(); revivebuf = 3;

func spring_to_target(target:Vector2, fraction:float = 0.9) -> void:
	position = lerp(position, lerp(startpos,target,fraction), 0.3)
	springbuf = 2

func _physics_process(_delta: float) -> void:
	if revivebuf > 0:
		revivebuf -= 1
		$spr.setup([40,41,42,43,10,11,12,13],5)
	elif ouchiebuf > 0:
		ouchiebuf -= 1
		$spr.setup([30,31,30,31,30,31,30,30,30,30,30,30,],3)
	elif springbuf > 0:
		springbuf -= 1
	else:
		ang += angvel
		$spr.setup([10,11,12,13],normal_aniperiod)
		position = lerp(position, startpos + hinge.rotated(ang), 0.4)

func play_ouchie() -> void:
	ouchiebuf = 5
