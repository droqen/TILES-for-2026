extends Node2D

const GRID = [
	['A','B','C','D','E','F'],
	['G','H','I','J','K','L'],
	['M','N','O','P','Q','R'],
	['S','T','U','V','W','X'],
	['Y','Z','BKSP',null,'NVM ',null],
]
var cx := 0; var cy := 0;

var guess_total : String = ""

var _looping := false

var flckrbuf := 0

signal done_looping

func loop_guessing() -> String:
	guess_total = ""
	flckrbuf = 10
	$Guess.hide()
	_looping = true
	cx = 0; cy = 0;
	reprint()
	await done_looping
	_looping = false
	if len(guess_total) == 4:
		return guess_total
	else:
		guess_total = ''
		reprint()
		return ''

func _ready() -> void:
	$Guess.hide()
	$Keyboard.hide()

func _physics_process(_delta: float) -> void:
	if flckrbuf > 0:
		flckrbuf -= 1
		$Keyboard.hide()
	elif _looping:
		$Guess.show()
		$Keyboard.show()
		var dpad_tap = Pin.get_dpad_tap()
		if dpad_tap and try_move(dpad_tap.x, dpad_tap.y):
			reprint()
		if Pin.get_action_hit():
			if GRID[cy][cx] == null: cx -= 1
			var word : String = GRID[cy][cx]
			match word:
				'BKSP':
					if len(guess_total):
						guess_total = guess_total.substr(0,len(guess_total) - 1)
						$bksp.play()
						flckrbuf = 5
					else:
						$bkspfail.play()
						flckrbuf = 5
					reprint()
				'NVM ':
					$leav.play()
					hide()
					done_looping.emit()
				_:
					$pick.play()
					guess_total += word
					flckrbuf = 5
					reprint()
					if len(guess_total) >= 4:
						done_looping.emit()
	else:
		$Keyboard.hide()

func try_move(dx:int, dy:int) -> bool:
	if flckrbuf > 0: return false
	if dx and GRID[cy][cx] == null: cx -= 1
	for _i in 2:
		cx = posmod(cx+dx,6)
		if GRID[cy][cx] != null: break
	cy = posmod(cy+dy,5)
	$move.play()
	return true # moving is always successful, why wouldnt it be?

func reprint() -> void:
	var kbtxt = ''
	for y in 5:
		for x in 6:
			var word = GRID[y][x]
			if word == null: continue
			var selected := (x==cx or (len(word)>1 and x+1==cx)) and y==cy
			kbtxt += "%s%s%s" % [
				"[" if selected else " ",
				word,
				"]" if selected else " ",
			]
		kbtxt += '\n\n'
	$Keyboard.text = kbtxt
	
	if len(guess_total) == 4:
		$Guess.text = '"%s"' % guess_total
	else:
		$Guess.text = '"%s%s"' % [guess_total,'_'.repeat(4-len(guess_total))]
