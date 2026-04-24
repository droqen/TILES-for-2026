extends Node2D

@onready var vessel : NavdiVessel = $"../V"

func shoot(
	player:Node2D,
	dir:Vector2i,
	posoffset:Vector2=Vector2.ZERO,
	)->void:
		(vessel
		.spawn_exile_by_name("PlayerPew", $PlayerPews)
		.setup(player.position + posoffset, dir)
		)
		
