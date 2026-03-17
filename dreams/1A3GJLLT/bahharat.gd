extends Node2D
@export var partner : Node2D

@onready var spr : SheetSprite = $spr

var __lost : int = 100
var __avoiding : int = 0
var __injured : int = 0
var __ouchflash : int = 0
var __invinc : int = 0
var __contacttimer : int = 0
var __spindir : float = 1.0
var __spindir_target : float = 1.0
var __wandering_to_x : float = randf_range(5,185)

var vel : Vector2

var dancedir : Vector2

func _physics_process(_delta: float) -> void:
	
	var chasing : bool = true
	if partner == null or !is_instance_valid(partner):
		if chasing: __wandering_to_x = randf_range(5,185)
		chasing = false
	elif partner.ducky:
		if __lost < 100:
			__lost += 1
		else:
			if chasing: __wandering_to_x = randf_range(5,185)
			chasing = false
	elif position.distance_to(partner.position) < 70:
		if __lost > 40:
			vel.x *= 0.5
			vel.y = -1.25
			$songs/thrill.play()
			# jump up when it thought player was gone
		__lost = 0
	else:
		chasing = false
		# player too far, i can't notice
	
	if chasing and __injured <= 0:
		if (position - partner.position).length_squared() < 100:
			if __avoiding <= 0:
				# avoid
				$songs/soft_startle.play()
			__avoiding = 100 + randi() % 25 # careful !!!
			if partner.ducky:
				__avoiding /= 2
			__spindir = 0
			__spindir_target = 0
	
	if position.x < 1:
		position.x = 1
		if vel.x < 0: vel.x *= 0.5
	
	if position.x > 189:
		position.x = 189
		if vel.x > 0: vel.x *= 0.5
	
	if (chasing
	and !partner.ducky
	and (position - partner.position).length_squared() < 25
	and __invinc <= 0):
		if __contacttimer <3:
			__contacttimer += 3
		else:
			__injured = 200 + randi() % 200 # oof, got too close
			__ouchflash = 3
			for node in $songs.get_children():
				node.stop()
			$crash.play()
			if position.x < partner.position.x:
				partner.vx = 2.0
				vel.x -= 2.0
			if position.x > partner.position.x:
				partner.vx = -2.0
				vel.x += 2.0
				spr.flip_h = true
			partner.vy = -2.0
			partner.bonky = true
			vel.y = vel.y * 0.5 + 2.0 # fallfast
	elif __contacttimer > 0:
		__contacttimer -= 1
	
	if __injured > 0:
		__invinc = 20
		__injured -= 1
		__contacttimer = 0
		__avoiding = 0
		
		vel.y += 0.04
		position += vel
		if position.y > 86 and vel.y >= 0:
			if vel.y > 0.5:
				vel.y *= -0.5
				$bounce.play() # bounce up
			else:
				vel.y = 0
				position.y = 86
		if __ouchflash > 0:
			__ouchflash -= 1
			spr.setup([40])
		elif vel.y == 0:
			vel.x *= 0.95
			if abs(vel.x) > 0.02:
				spr.setup([51])
			else:
				spr.setup_forcechangeindex([51,52,53],30)
		elif vel.y < 0: # flying up
			spr.setup([61,62,63],15)
		else: # fallin down
			spr.setup([41,42,43],10)
		
		if __injured == 0:
			spr.flip_h = false
			vel.y = -1.0
			# awake from being injured
			$songs/chirrup.play()
			
		if spr.frame in [51,52,53]:
			spr.position.y = 4
		else:
			spr.position.y = 0
	else:
		
		if __invinc > 0:
			__invinc -= 1
			if __invinc % 5 > 2: spr.hide()
			else: spr.show()
		spr.flip_h = false
		
		if chasing:
			if randf() < 0.01:
				sing()
			if __avoiding > 0:
				dancedir = (position - partner.position).normalized()
				__avoiding -= 1
				
			dancedir = dancedir.rotated(0.01 * __spindir)
			if randf() < 0.01 or __spindir_target == 0:
				__spindir_target = randf_range(0.5, 2.0) * [-1,1][randi()%2]
			__spindir = move_toward(__spindir,__spindir_target,0.05)
			var partnervel := Vector2(partner.vx, partner.vy)
			var targetpos = (partner.position
			+ partnervel * 5
			+ dancedir * (15 + __avoiding*0.33)
			)
			var totarget = targetpos - position
			var targetvel = (totarget*0.2).limit_length(1.0) + partnervel
			vel += (targetvel-vel).limit_length(0.05)
			position += vel
			if position.y > 86:
				if vel.y > 0:
					vel.y *= -1
			elif position.y > 83:
				if vel.y > 0:
					vel.y *= 0.8
			spr.setup([20,21,22,23],10)
		else:
			if randf() < 0.003: # rarer to sing when not chasing
				sing()
			vel *= 0.98
			if vel.y < 0:
				vel.x = move_toward(vel.x, sign(__wandering_to_x - position.x) * 0.15, 0.015)
			else:
				vel.x = move_toward(vel.x, sign(__wandering_to_x - position.x) * 0.05, 0.005)
			if abs(__wandering_to_x - position.x) < 1:
				__wandering_to_x = randf_range(5,185)
			vel.y += 0.01
			position += vel
			if position.y > 86:
				if vel.y > 0:
					vel.y *= -1
					if randf() < 0.015:
						vel.y = randf_range(-0.2,-0.7)
			elif position.y > 83:
				if vel.y > 0:
					vel.y *= 0.8
					if randf() < 0.002:
						vel.y = randf_range(-0.2,-0.7)
			spr.setup([20,21,22,23],15)
		
		spr.position.y = 0

func sing() -> void:
	var song : NavdiBeep = $songs.get_child(randi()%$songs.get_child_count())
	song.play()
