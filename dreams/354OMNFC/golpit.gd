extends EnemyParent
const EnemyParent = preload("res://dreams/354OMNFC/enemy_parent.gd")

var vel : Vector2
var supervel : Vector2

var hp := 5

var fizzing : bool :
	get : return bufs.has(FIZZBUF)

enum {SHOTBUF, FIZZBUF,}

func setup(pos,_stage,_targetplayer):
	super.setup(pos,_stage,_targetplayer)
	return self

func setup_bufs():
	super.setup_bufs()
	bufs.setup_bufons([SHOTBUF, 4, FIZZBUF, 20, ])
	return self

func setup_copyfrom(same):
	var borrowedvel : Vector2 = same.vel
	borrowedvel = borrowedvel.rotated(randf()-randf())
	bufs.setmin.call_deferred(SHOTBUF, 20)
	supervel = same.vel * 0.5
	vel = same.vel * 0.5
	position = same.position + vel
	return self

func _physics_process(_delta: float) -> void:
	check_boxes()
	
	position += supervel
	supervel *= 0.95
	
	if bufs.has(SHOTBUF):
		spr.setup([60,61],2)
		spr.position = Vector2(randi()%5-2, randi()%5-2)
	elif bufs.has(FIZZBUF):
		spr.setup_trywaitformatch([60,61],15)
		spr.position *= 0.9
		if bufs.read(FIZZBUF) == 1: onwannadie.emit()
	else:
		supervel *= 0
		spr.setup([50,51,52],12)
		spr.position = Vector2(0,0)
		if is_instance_valid(targetplayer):
			vel = lerp(vel, (targetplayer.position as Vector2 - position).limit_length(1.0), 0.02)
		else:
			var to_exit := Vector2(135,75) - position
			vel = lerp(vel * 0.98, to_exit.limit_length(1.0), 0.02)
			if to_exit.length() < 1 and vel.length() < 0.5:
				queue_free()
			#vel *= 0.98
		position += vel

func process_foe_interaction(otherfoe) -> void:
	var to_otherfoe : Vector2 = otherfoe.position - position
	var distsq = to_otherfoe.length_squared()
	if distsq < 20 * 20:
		# repel
		vel -= 0.1 * (to_otherfoe / max(1,distsq))

func on_hit_by(bullet) -> void:
	if bullet.vel.x:
		vel.x = 1.0 * sign(bullet.vel.x)
	if bullet.vel.y:
		vel.y = 1.0 * sign(bullet.vel.y) 
	bufs.on(SHOTBUF)
	if bufs.has(FIZZBUF): bufs.on(FIZZBUF)
	hp -= 1
	onimhit.emit(hp)
	if hp <= 0: onwannadupe.emit(); hp = 5;

func exec_hurt(_target : Node2D) -> void:
	#print("i hurt target ",target)
	bufs.on(SHOTBUF)
	bufs.on(FIZZBUF)
	vel *= 0
