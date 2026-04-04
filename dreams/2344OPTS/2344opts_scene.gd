extends Node2D

func _ready() -> void:
	$UILayer.maze = $World/Maze
	$UILayer.player = $World/Naut
	while is_instance_valid($UILayer.player):
		$UILayer/ViewRoot/LabelMenu.show()
		await $UILayer.loop_until_player_choice()
		$UILayer/ViewRoot/LabelMenu.hide()
		await get_tree().create_timer(0.1).timeout
	
