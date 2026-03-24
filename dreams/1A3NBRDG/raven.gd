extends Node2D

enum {
	STATE_CHILL_FWD,
	STATE_CHILL_BACK,
	STATE_RUFFLE_FWD,
	STATE_FWD_TO_BACK,
	STATE_BACK_TO_FWD,
	STATE_HOP_FWD,
	STATE_HOP_BACK,
	STATE_TAKEOFF,
	STATE_FLYING,
	STATE_CAW_FWD,
	STATE_CAW_BACK,
}

var curstate = STATE_CHILL_FWD
var state_period := 0.1
var state_subanif := 0.0
var cool := 5
var real_cool := 5
var vx := 0.0
var vy := 0.0
var prevflyingframe := 0

func goto_state(s, state_period_mult:float = 1.0) -> void:
	curstate = s
	match curstate:
		STATE_CHILL_FWD: state_period = 0.03
		STATE_CHILL_BACK: state_period = 0.03
		STATE_RUFFLE_FWD:
			state_period = 1.0
		STATE_FWD_TO_BACK, STATE_BACK_TO_FWD:
			state_period = 0.1
		STATE_HOP_FWD, STATE_HOP_BACK:
			state_period = 0.1
		STATE_TAKEOFF: state_period = 0.1
		STATE_FLYING:
			vx = randf_range( 0.3, 0.6)
			vy = randf_range(-0.25,-0.55)
			#if is_instance_valid(player):
				#spr.flip_h = player.position.x > position.x
				#if spr.flip_h: vx *= -1
			state_period = randf_range(0.5,0.8)
			Dreamer.w("raven_left", true) # never gon see me again
		STATE_CAW_FWD, STATE_CAW_BACK:
			state_period = 0.2; play_caw()
	state_period *= state_period_mult
	state_subanif = 0.0

@onready var player : Node2D = NavdiSolePlayer.GetPlayer(self)
@onready var spr : SheetSprite = $spr
func _ready() -> void:
	if Dreamer.r("raven_left"):
		hide()
		queue_free()
	else:
		if randf()<0.1:
			goto_state(STATE_RUFFLE_FWD)
		elif randf()<0.02:
			goto_state(STATE_FWD_TO_BACK)
		elif randf()<0.1:
			goto_state(STATE_BACK_TO_FWD)
func _physics_process(delta: float) -> void:
	if is_instance_valid(player):
		if player.position.x < 20 or player.position.x > 130:
			cool = 5
		else:
			if player.doing_something_weird:
				if randf() < 0.01: real_cool -= 1
			cool = real_cool
	state_subanif += delta
	var endofperiod := state_subanif >= state_period
	match curstate:
		STATE_CHILL_FWD:
			setspr_subanif([40])
			if endofperiod:
				match randi()%maxi(30+cool,20) + cool:
					0,1,2,3,4: goto_state(STATE_TAKEOFF)
					10: goto_state(STATE_CAW_FWD)
					11: goto_state(STATE_FWD_TO_BACK)
					12: goto_state(STATE_RUFFLE_FWD)
		STATE_CHILL_BACK:
			setspr_subanif([44])
			if endofperiod:
				match randi()%maxi(30+cool,20) + cool:
					0,1,2,3,4: goto_state(STATE_TAKEOFF)
					10: goto_state(STATE_CAW_BACK)
					11,12: goto_state(STATE_BACK_TO_FWD)
		STATE_RUFFLE_FWD:
			setspr_subanif([41,42,42,42,41,41,42,41,41,42,42,41])
			if endofperiod: goto_state(STATE_CHILL_FWD)
		STATE_FWD_TO_BACK:
			setspr_subanif([43])
			if endofperiod: goto_state(STATE_CHILL_BACK)
		STATE_BACK_TO_FWD:
			setspr_subanif([43])
			if endofperiod: goto_state(STATE_CHILL_FWD)
		STATE_HOP_FWD:
			setspr_subanif([45])
			if endofperiod: goto_state(STATE_CHILL_FWD)
		STATE_HOP_BACK:
			setspr_subanif([45])
			if endofperiod: goto_state(STATE_CHILL_BACK)
		STATE_TAKEOFF:
			setspr_subanif([47])
			if endofperiod: goto_state(STATE_FLYING)
		STATE_FLYING:
			setspr_subanif([48, 49,59,59,49, 48,48,48,])
			if spr.frame != prevflyingframe:
				if prevflyingframe == 48 and spr.frame == 49:
					play_flap()
				prevflyingframe = spr.frame
			match spr.frame:
				49,59:
					position.x += vx * 1.2
					position.y += vy
				48:
					position.x += vx * 0.8
					position.y += vy * 0.5
			if endofperiod:
				state_period = randf_range(0.5,0.8)
		STATE_CAW_FWD:
			setspr_subanif([50])
			if endofperiod: goto_state(STATE_CHILL_FWD)
		STATE_CAW_BACK:
			setspr_subanif([54])
			if endofperiod: goto_state(STATE_CHILL_BACK)
	state_subanif = fposmod(state_subanif, state_period)
func setspr_subanif(frames:Array[int]) -> void:
	if len(frames) > 2:
		var p := state_subanif/state_period
		spr.setup([frames[posmod(int(p * len(frames)), len(frames))]])
	elif frames:
		spr.setup(frames)
func play_caw() -> void:
	var caw_beeps = get_tree().get_nodes_in_group("caw_beep")
	if caw_beeps:
		(caw_beeps[randi()%len(caw_beeps)] as NavdiBeep).play()
func play_flap() -> void:
	var flap_beep = get_tree().get_first_node_in_group("flap_beep")
	if flap_beep:
		if position.y < -20:
			queue_free()
		else:
			flap_beep.play()
			if position.y < 20:
				flap_beep.volume = 0.6
