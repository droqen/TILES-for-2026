extends Node2D

@onready var aeBAHHAPICK = $Entities/Bahha/PickMenu
@onready var aeJALLETRESPOND = $Entities/TextLog
@onready var aeJALLETLEAVE = $Entities/Jallet

signal booped
var boopbuf := 0

# ensure is same as in pick_menu.gd
enum {
	PA_greet, PA_smalltalk, PA_leave, PA_points, PA_points_lots, PA_wait,
}

var jallet_left := false

func _ready() -> void:
	aeBAHHAPICK.hide()
	await say (["There is a Jallet. ",'-'])
	$Stage/bgm.play()
	while not jallet_left:
		var pa = await aeBAHHAPICK.loop_until_select_player_action()
		#$Stage/bgm.stop()
		print("done, chose: ",pa)
		match pa:
			PA_greet:
				if Dreamer.r("helloed"):
					await say([
						"Hello again. ",
						"(hello) (again) ",
					"-"])
				else:
					Dreamer.w("helloed",true)
					await say([
						"Hello. ",
						"(hello) ",
					"-"])
			PA_smalltalk:
				Dreamer.w("smalltalked",Dreamer.r("smalltalked",-1)+1)
				match (randi() % 3 + Dreamer.r("smalltalked")) % 10:
					0:
						await say([
							"It is a nice dance. (dance) (it is) ",
						"-"])
					1:
						await say([
							"The weather. (weather) ",
						"-"])
					2:
						await say([
							"Can I dance? (dance) (can dance) ",
						"-"])
					3:
						await say([
							"Dangerous. (danger) (dangerous) ",
						"-"])
					4:
						await say([
							"Your name? (name) (question) ",
						"-"])
					5:
						await say([
							"It is plain. (plain) ",
						"-"])
					6:
						await say([
							"Plain is safety. (plain) (not danger) ",
						"-"])
					7:
						await say([
							"There is dance. (dance) (dancing) ",
						"-"])
					8:
						await say([
							"Dance is safety. (dance) (dancing) (not dancer) ",
						"-"])
					9:
						await say([
							"Jalleter. (Jallet) ",
						"-"])
			PA_points, PA_points_lots:
				await say([
					"Ah. . . \n points? \nDo not ask. (points) (not ask) ",
				"-"])
				Dreamer.w("times_asked",Dreamer.r("times_asked",0)+1)
				await get_tree().create_timer(Dreamer.r("times_asked",0)*0.5).timeout
			PA_wait:
				boopbuf = 3
				await booped
				boopbuf = 0
			PA_leave:
				await say([
					"Okay. Good- ",
					"bye. (okay) ",
					" (good-bye) ","-"])
				aeJALLETLEAVE.hide(); jallet_left = true;
				await say([
					"Jallet left. ","-"])
			_: pass
	
	print("end of input.")

func _physics_process(_delta: float) -> void:
	if boopbuf > 1:
		boopbuf -= 1
	elif boopbuf == 1:
		if Pin.get_action_hit(): booped.emit.call_deferred()

func say(msgs:Array[String]):
	await aeJALLETRESPOND.loop_until_advance("\n".join(msgs))
