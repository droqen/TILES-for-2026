extends Node2D

@onready var vessel : NavdiVessel = $"../NavdiVessel"
@onready var poppedBubblesParent = $"../PoppedBubbles"

func _physics_process(_delta: float) -> void:
	if randf() < 0.01:
		var bubble = vessel.spawn_exile_by_name("Bubble", self)
		bubble.position = Vector2(194, randi_range(5,57))
		bubble.popped_at.connect(func(pos):
			if is_instance_valid(vessel) and is_inside_tree():
				var pb = vessel.spawn_exile_by_name("PoppedBubble", poppedBubblesParent)
				pb.position = pos
				await get_tree().create_timer(randf_range(0.07,0.10)).timeout
				if is_instance_valid(pb): pb.queue_free() # bye
		)
