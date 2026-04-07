extends Node2D

func _ready() -> void:
	renderfp.call_deferred()

func renderfp() -> void:
	$Firstperson/Folder.render34($Topdown.get34solidsatplayer())

func _physics_process(_delta: float) -> void:
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
