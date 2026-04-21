extends Label

@export var lines : Array[String] = [
	"DRAG & DROP YOUR",
	".PCK FROM DROQEN"
]

@export var initial_delay : float = 0.1
@export var delay_between_lines : float = 0.1
var mindex : int
var delay : float = 0.0

func _ready() -> void:
	mindex = len(lines)
	text = ''
	await get_tree().create_timer(initial_delay).timeout
	while mindex > 0:
		if not is_inside_tree(): return
		mindex -= 1
		text = "\n".join(lines.slice(mindex))
		if mindex > 0: await get_tree().create_timer(delay_between_lines).timeout
	#queue_free()
	# stop processing - but don't delete me lol
