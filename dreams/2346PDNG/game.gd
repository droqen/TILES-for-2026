extends Node2D

func _ready() -> void:
	renderfp.call_deferred()

func renderfp() -> void:
	$Firstperson/Folder.render34($Topdown.get34solidsatplayer())
	var distance_to_white = $Topdown.get_distance_to_white_player()
	$Firstperson/WhtFolder.update_lookinatwhite(distance_to_white)

func _physics_process(_delta: float) -> void:
	if not $Topdown.gameover:
		var dpad_tap := Pin.get_dpad_tap()
		if dpad_tap.x : 
			$Topdown.control_player_turn(dpad_tap.x)
			renderfp()
			$Firstperson/Folder.animate_turn(dpad_tap.x)
		elif dpad_tap.y :
			if $Topdown.control_player_try_step(-dpad_tap.y):
				renderfp()
				if dpad_tap.y < 0:
					$Firstperson/Folder/RectRenderer.animate_fwd()
				else:
					$Firstperson/Folder/RectRenderer.animate_bkwd()
