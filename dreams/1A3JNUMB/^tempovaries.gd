extends Node

@onready var beep : NavdiBeep = get_parent()
var tempo : float = 150.0
var targettempo : float = 150.0
var tochange : int = 0

func _physics_process(_delta: float) -> void:
	if tochange > 0:
		tochange -= 1
	else:
		tochange = randi_range(100,1000)
		targettempo = 100 + randf()*50 + randf()*50
	tempo = lerp(tempo,targettempo,0.05)
	if beep.tempo != int(tempo):
		beep.tempo = int(tempo)
