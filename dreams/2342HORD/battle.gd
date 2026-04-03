extends Node2D

@onready var vessel : NavdiVessel = $V
@onready var maze : Maze = $"Maze(bg)"

const PEACE : bool = true

enum {NAME, POS, FRMPRD}
enum {BS_START, BS_PLAYERCHOOSE, BS_ANIMATING, BS_PLAYERGONE}
var battlestate = BS_START
var battlestate_age := 0
var player_dodging := false
var player_wishing := false
enum {AE_PLAYERCUT,AE_GLB_ATTACK,AE_PLAYERLEAVE,AE_GLB_REVIVE,AE_NOTHING,AE_PLAYERSILLYDODGE}
var anims = []

class BattleAnim:
	var actor
	var target
	var action
	var age : int
	var phase : int
	var done : bool
	func _init(_actor,_target,_action) -> void:
		self.actor = _actor
		self.target = _target
		self.action = _action
		age = 0; phase = 0
	func anim_update(p) -> void:
		age += 1
		match [action, phase]:
			[AE_NOTHING, _]:
				if age >= 60: done = true;
			 
			[AE_PLAYERCUT, 0]:
				actor.spring_to_target(target.position)
				if age >= 10 and age < 25: actor.chaargebuf = 3
				if age == 13: p.get_node("player_attk").play()
				if age >= 15: target.play_ouchie()
				if age >= 30: age = 0; phase += 1; target.hide()
			[AE_PLAYERCUT, 1]:
				if age >= 25: phase += 1
			#done.
			
			[AE_PLAYERSILLYDODGE, 0]:
				if age >= 43 and age < 54: actor.q_dodge()
				if age == 48: p.get_node("player_dodge").play()
				if age >= 90: done = true;
			
			[AE_GLB_ATTACK, 0]:
				if actor.visible:
					if p.player_dodging:
						if age >= 3 and age < 14: target.q_dodge()
						if age == 8: p.get_node("player_dodge").play()
						if age < 14: actor.spring_to_target(target.position)
						if age >= 26: age = 0; phase += 1;
					else:
						actor.spring_to_target(target.position)
						if age == 12: p.get_node("player_hurt").play()
						if age >= 12: target.play_ouchie();
						if age >= 17: age = 0; phase += 1;
				else:
					done = true
			#done.
			
			[AE_GLB_REVIVE, 0]:
				if age >= 30:
					if age == 30: p.get_node("glb_revive").play()
					actor.q_revive()
					if age >= 60: done = true
			
			[AE_PLAYERLEAVE, 0]:
				if is_instance_valid(actor):
					actor.q_leave()
				else:
					done = true
			
			_:
				done = true

func _ready() -> void:
	var periods = [8,9,10,11,12]; periods.shuffle();
	var letters = "ABCD"
	for i in $GLBstarts.get_child_count():
		var start = $GLBstarts.get_child(i).position
		(vessel
		.spawn_exile_by_name("GLBA", $GLBS)
		.setup(start, letters[i], periods[i])
		)
	for x in range(2,11+1):
		for y in range(1,10+1):
			var c : Vector2i = Vector2i(x,y)
			var t := maze.get_cell_tid(c)
			match [maze.get_cell_tid(c+Vector2i.LEFT), t]:
				[20,22],[23,22]: t = 21
				[21,20],[22,20]: t = 23
			maze.set_cell_tid(c, t)
	$PLAYERMENU.confirmed_final_action.connect(func(action_stack):
		player_dodging = action_stack[0] == "DODGE"
		player_wishing = action_stack[0] == "WISH"
		if action_stack[0] == "CUT":
				anims.append(BattleAnim.new(
					$SWORDER,
					get_node("GLBS/GLB%s"%action_stack[1]),
					AE_PLAYERCUT )) #
		print(action_stack)
		if action_stack[0] == "LEAVE":
			$player_esc.play()
			anims.append(BattleAnim.new($SWORDER,null,AE_PLAYERLEAVE))
		elif not PEACE:
			for glb in $GLBS.get_children():
				anims.append(BattleAnim.new(glb, $SWORDER, AE_GLB_ATTACK))
			anims.shuffle()
		elif player_dodging:
			anims.push_front(BattleAnim.new($SWORDER, null, AE_PLAYERSILLYDODGE))
			
		if player_wishing or action_stack[0] == "WAIT":
			anims.push_front(BattleAnim.new(null, null, AE_NOTHING))
		if player_wishing:
			anims.push_front(BattleAnim.new(null, null, AE_NOTHING))
		battlestate = BS_ANIMATING
		battlestate_age = 0
	)

func _physics_process(_delta: float) -> void:
	if battlestate_age < 9999: battlestate_age += 1
	match battlestate:
		BS_START:
			$PLAYERMENU.hide(); $PLAYERMENU.update_reset();
			if battlestate_age > 50:
				battlestate = BS_PLAYERCHOOSE
				battlestate_age = 0
		BS_PLAYERCHOOSE:
			$PLAYERMENU.show(); $PLAYERMENU.update_control()
		BS_ANIMATING:
			if has_node("SWORDER"):
				if player_wishing: $SWORDER.q_wish()
				if anims:
					$PLAYERMENU.update_reset()
					anims[0].anim_update(self)
					if anims[0].done:
						anims.pop_front()
				else:
					# any invisible glbs?
					for glb in $GLBS.get_children():
						if not glb.visible:
							anims.append(BattleAnim.new(glb,null,AE_GLB_REVIVE))
					if not anims:
						battlestate_age += 1
						if battlestate_age > 20:
							battlestate = BS_PLAYERCHOOSE
							battlestate_age = 0
			else:
				battlestate = BS_PLAYERGONE
				battlestate_age = 0
				$bgm.tempo = 150
				#$bgm.stop()
				#$bgm_drumsolo.play()
		BS_PLAYERGONE:
			$PLAYERMENU.update_reset()

		
