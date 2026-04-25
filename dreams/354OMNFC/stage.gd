extends Node2D

@export var player : Node2D

@onready var vessel : NavdiVessel = $"../V"

func _ready() -> void:
	spawnfoe.call_deferred("golpit")

func shoot(
	shooter:Node2D,
	dir:Vector2i,
	posoffset:Vector2=Vector2.ZERO,
	)->void:
		(vessel
		.spawn_exile_by_name("PlayerPew", $PlayerPews)
		.setup(shooter.position + posoffset, dir)
		)

func spawnfoe(foename)->void:
	(vessel
	.spawn_exile_by_name(foename, $Foes)
	.setup(
			Vector2(20,20),
			self,
			self.player,
		)
	)
