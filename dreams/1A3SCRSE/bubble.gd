extends Area2D
var phase := 3
var sprphase := 3
var filled := 0
var vx := 0.0
var vy := 0.0
var wobbla := 0.0
@onready var overlap : Area2D = $bubble_overlap_det
signal popped_at(pos)
func _ready() -> void:
	vx = -1
	vy = randf_range(-1,1)
	filled = randi() % 4
	wobbla = randf() * 3.14
	$SheetSprite.setup([16+filled],0)
func _physics_process(_delta: float) -> void:
	wobbla += 0.01
	if phase <3:
		phase += 1
	else:
		phase = 0
		position.x += vx
		if position.x < -5:
			position.x = 195
		position.y += vy
		if $RayCast2D.is_colliding():
			vx = move_toward(vx, 0.5, 0.07)
			vy = move_toward(vy, sin(wobbla) * 0.2 - 0.4, 0.05)
		else:
			vx = move_toward(vx, -1.0, 0.05)
			vy = move_toward(vy, sin(wobbla) * 0.2 + 0.1, 0.05)
		if sprphase <5:
			sprphase += 1
		else:
			sprphase = 0
			filled += randi() % 3 - 1
			if filled < 0: filled = 1
			if filled > 3: filled = 2
			$SheetSprite.setup([16+filled],0)
	
	var os = overlap.get_overlapping_areas()
	if len(os) <3:
		for o in os:
			var imup = sign(position.y - o.position.y)
			vy += imup * 0.01
			o.vy -= imup * 0.01
	else:
		var imabovesomeone := false
		for o in os:
			if position.y < o.position.y:
				imabovesomeone = true
				break
		if not imabovesomeone: pop()
	
func pop() -> void:
	popped_at.emit(position)
	queue_free()
