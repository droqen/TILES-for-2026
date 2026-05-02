extends Node2D

@onready var v : NavdiVessel = $"../v"

func spawn_pbullet(pos : Vector2):
	var pbullet = v.spawn_exile_by_name("pbullet",$pbullets)
	pbullet.position = pos
	return pbullet

func spawn_edeath(pos : Vector2):
	var edeath = v.spawn_exile_by_name("edeath",$pbullets)
	edeath.position = pos
	return edeath

var spawnx : int = 0
var spawntimer : float = 0.1

func _physics_process(delta: float) -> void:
	if spawntimer > 0:
		spawntimer -= delta
	else:
		spawntimer += 0.1 - delta
		spawnx += 1
		if spawnx >= 20: spawnx -= 19
		var availableys := [1,2,3]
		for eship in $eships.get_children():
			if eship.x == spawnx: availableys.erase(eship.y)
			if len(availableys) == 0: break
		if len(availableys):
			(v
				.spawn_exile_by_name("epacer", $eships)
				.setup(spawnx, availableys[0], $Maze
					.map_to_local(
						Vector2i(
							spawnx,
							availableys[0]
						)
					)
				)
			)
