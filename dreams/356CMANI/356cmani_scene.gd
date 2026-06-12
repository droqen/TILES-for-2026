extends Node2D

@onready var player = $player
var fade : float = 1.0
var lastvischars : int = -1
func _ready() -> void:
	player.died.connect(func(): self.player = null)
func _physics_process(_delta: float) -> void:
	if player:
		if player.position.x < 100:
			$player/bgm_notes.volume = (player.position.x) / 100
			$bgm_noise.volume = 0
		elif player.position.x <= 200:
			$bgm_noise.volume = (player.position.x - 100) / 100
	else:
		if fade > 0:
			fade -= 0.0001
			fade *= 0.999
			$Label.visible_ratio = fade
			$bgm_noise.tempo = int(lerp(140,20,fade))
			if fade < 0.5:
				$bgm_noise.volume = sqrt(fade * 2)
			if fade <= 0:
				$Label.hide()
				$bgm_noise.stop()
				if lastvischars > 0:
					$bksp.play()
					lastvischars = 0
			else:
				var vischars : int = $Label.visible_characters
				if vischars != lastvischars:
					if vischars >= 0 and vischars < len($Label.text):
						match $Label.text[vischars]:
							' ', '\n': pass
							_: $bksp.play()
					lastvischars = vischars
