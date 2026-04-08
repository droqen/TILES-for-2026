extends Node2D

@onready var scores = get_children()
var score_actives : Array[bool] = [1,0,0,0,0,0,]
var score_start_positions : Array[Vector2]
const SCORE_MIN_OFFSETS : Array[Vector2i] = [
	Vector2i(-11,-21),
	Vector2i(-11,0),
	Vector2i(-40,-16),
	Vector2i(-26,0),
	Vector2i(-21,-16),
	Vector2i(-11,0),
]
const SCORE_MAX_OFFSETS : Array[Vector2i] = [
	Vector2i(41,0),
	Vector2i(30,16),
	Vector2i(12,0),
	Vector2i(11,11),
	Vector2i(21,0),
	Vector2i(21,16),
]

func _ready() -> void:
	for score in scores:
		score_start_positions.append(score.position)
		score.hide()
	scores[0].show()
	score_actives[0] = true

var phase := 5

func _physics_process(_delta: float) -> void:
	if phase > 0:
		phase -= 1
	else:
		phase = 5
		var active_count := len(score_actives.filter(func(a):return a))
		for i in len(scores):
			if randf() < 0.1:
				if score_actives[i]:
					if randi_range(1, 10) < active_count:
						score_actives[i] = false;
						active_count -= 1
				else:
					if randi_range(1, 4+active_count) == 1:
						score_actives[i] = true;
						if not scores[i].visible:
							scores[i].position = score_start_positions[i] + Vector2(
								randi_range(SCORE_MIN_OFFSETS[i].x, SCORE_MAX_OFFSETS[i].x),
								randi_range(SCORE_MIN_OFFSETS[i].y, SCORE_MAX_OFFSETS[i].y),
							)
							scores[i].position.x = round(scores[i].position.x/5)*5
							scores[i].position.y = round(scores[i].position.y/5)*5
			if score_actives[i]:
				if not scores[i].visible:
					scores[i].show()
					scores[i].modulate.a = 0.5
				elif scores[i].modulate.a < 1:
					scores[i].modulate.a = 1
			else:
				if scores[i].modulate.a > 0.5:
					scores[i].modulate.a = 0.5
				else:
					scores[i].hide()
