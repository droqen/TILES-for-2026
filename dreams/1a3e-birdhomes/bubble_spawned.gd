extends Node2D
@onready var spr := $SheetSprite
var poppy : int = 0
func _ready() -> void:
	spr.setup([],randi_range(40,60))
func _physics_process(_delta: float) -> void:
	if poppy > 0:
		poppy -= 1
		if poppy <= 0: queue_free()
		return
	if is_instance_valid(watched_player):
		if position.distance_to(watched_player.position) < 5:
			watched_player.play_pop_sound()
			spr.setup([29])
			poppy = 5
			return
	position.y -= 0.05
	if spr.ani_subindex == 0:
		if position.y < -7:
			queue_free() # disappear
		else:
			position.y -= 1
			position.x += randi_range(-1,1)
var watched_player : Node2D
func watch_player(maybe_player):
	if is_instance_valid(maybe_player) and maybe_player is Node2D:
		watched_player = maybe_player as Node2D
