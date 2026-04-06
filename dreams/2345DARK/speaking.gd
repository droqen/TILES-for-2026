extends Node2D

enum { GUESS, WRONG, WRONG_AGAIN, LEAVE, }
const PHRASES = {
	GUESS:'''
GUESS THE PASSWORD
TO ENTER MY SECRET
ROOM.''',
	WRONG:'''
NOPE! IT'S TOTALLY
NOT XXXX!! BUT TRY
AGAIN HA HA HA. :)''',
	WRONG_AGAIN:'''
HMM... PRETTY SURE
YOU TRIED THAT ONE
ALREADY.''',
	LEAVE:'''
YOU WILL NEVER GET
ACCESS TO A SECRET
WITH THAT ATTITUDE''',
}
signal completed_speaking
var typebuf := 0
var guess_history = []
var _saying := false
func _ready() -> void:
	$Speechbox.text = ''
	$Speechbox.visible_characters = 1
func loop_say_guess():
	await loop_thinking()
	_saying = true
	$Speechbox.text = PHRASES[GUESS]
	$Speechbox.visible_characters = 0
	await completed_speaking
func loop_say_wrong(guessed:String):
	await loop_thinking()
	_saying = true
	#print(guess_history,guessed,guess_history.has(guessed))
	if guess_history.has(guessed):
		$Speechbox.text = PHRASES[WRONG_AGAIN].replace("XXXX",guessed)
	else:
		guess_history.append(guessed)
		$Speechbox.text = PHRASES[WRONG].replace("XXXX",guessed)
	$Speechbox.visible_characters = 0
	await completed_speaking
func loop_say_leave():
	_saying = true
	$Speechbox.text = PHRASES[LEAVE]
	$Speechbox.visible_characters = 0
	await completed_speaking
func loop_thinking():
	$thinking.play()
	await get_tree().create_timer(randf_range(0.5,1.0)).timeout
	$thinking.stop()
func _physics_process(_delta: float) -> void:
	var vc : int = $Speechbox.visible_characters
	var ct : int = len($Speechbox.text)
	if typebuf > 0:
		typebuf -= 1
		$Head.setup([4,3],12)
		$Mouth.setup_trywaitformatch([14],0)
	elif vc < ct:
		typebuf = 7;
		for i in min(3,ct-vc):
			var c = $Speechbox.text[vc]
			vc += 1
			if c == ' ' or c == '\n':
				typebuf = 14; break
		$Speechbox.visible_characters = vc
		$type1.play()
		$Head.setup([4,3],20); $Head.ani_index = 0;
		$Mouth.setup([13,14,14,],4)
	else:
		$Head.setup_trywaitformatch([3],0)
		$Mouth.setup([14],0)
		if _saying:
			_saying = false
			completed_speaking.emit()
