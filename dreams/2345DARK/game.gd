extends Node2D

@onready var vessel : NavdiVessel = $V;

func _ready() -> void:
	await $Speaking.loop_say_guess()
	while true:
		var guess = await $Guessing.loop_guessing()
		if guess:
			await $Speaking.loop_say_wrong(guess)
		else:
			await $Speaking.loop_say_leave()
			break
