extends Node2D

const LINES : Array[String] = [
	"hello im KING",
	"and i decree:",
	"",
	"your score is",
	"           0."
]
var faceleft := true
var turnbuf := 0
var lastlinerevealed := -1
var subreveal := 5
var speaking := false
var tobored := 100
@onready var tinyguy = NavdiSolePlayer.GetPlayer(self)
func _ready() -> void:
	$Label.text = ''
	$ColorRect.size.y = 0
	if Dreamer.r("scored_by_king"):
		lastlinerevealed = 4 # done.
		tobored = randi_range(-100,100)
	else:
		tobored = randi_range(50,200)
	await get_tree().process_frame
	if is_instance_valid(tinyguy):
		if tobored > 0:
			faceleft = tinyguy.position.x < position.x
			$spr.flip_h = faceleft
			if !faceleft: $spr.setup([30])
func _physics_process(_delta: float) -> void:
	if not speaking:
		if tinyguy.position.x >= 29.5 and tinyguy.position.y >= 45.5:
			speaking = true
	elif subreveal > 0:
		subreveal -= 1
	elif lastlinerevealed <4:
		subreveal = 60
		lastlinerevealed += 1
		$Label.text = ''
		for i in range(lastlinerevealed-1,lastlinerevealed+1):
			if i >= 0:
				$Label.text += LINES[i] + '\n'
		$ColorRect.size.y = 5 if lastlinerevealed == 0 else 10
		if LINES[lastlinerevealed]:
			$spr.setup([21,20],8)
		else:
			$spr.setup([20])
	else:
		$spr.setup([20])
		Dreamer.w("scored_by_king",1)
	
	if lastlinerevealed >= 4 and tobored > 0:
		tobored -= 1
	
	var wannafaceleft : bool = (
		tinyguy.position.x < position.x)
	if tobored <= 0: wannafaceleft = true
	if wannafaceleft != faceleft:
		faceleft = !faceleft
		$spr.flip_h = faceleft
		turnbuf = 4
	var below : bool = abs(tinyguy.position.x - position.x) < 50
	if tobored <= 0: below = false # meh.
	var b : int = 10 if below else 0
	if turnbuf > 0:
		turnbuf -= 1
		$spr.setup([22+b])
	elif not speaking or subreveal < 20:
		$spr.setup([20+b])
	else: match lastlinerevealed:
		2:
			$spr.setup([20+b])
		_:
			$spr.setup([21+b,20+b],8)
