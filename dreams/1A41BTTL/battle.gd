extends Node2D

enum Phase {
	PlayersTurn,
	PlayersMessage,
	SlimesTurn,
	SlimesMessage,
	NoPlayer,
}

var phase_age : int = 0
var phase : Phase = Phase.SlimesMessage
var last_player_action = START
var slime_attack : bool = false

enum {
	START,
	PUNCH, PUNCH_MISS,
	MAGIC,
	LEAVE,
}

const ChoiceLabel = preload("res://dreams/1A41BTTL/choice.gd")
@onready var choice_label : ChoiceLabel = $UI/playerturn/Choice

func _ready() -> void:
	set_phase(Phase.SlimesMessage,
		"A PURPLE1 appears!")
	choice_label.chose_punch.connect(func():
		perform_player_action(PUNCH)
	)
	choice_label.chose_magic.connect(func():
		perform_player_action(MAGIC)
	)
	choice_label.chose_leave.connect(func():
		perform_player_action(LEAVE)
	)

func set_phase(_phase : Phase, message : String = ' ...') -> void:
	var phasewas : Phase = self.phase
	if _phase == Phase.PlayersTurn:
		$UI/outcomebox.hide()
		await get_tree().create_timer(0.1).timeout
	if is_inside_tree() and self.phase == phasewas:
		self.phase = _phase
		self.phase_age = 0
		$UI/playerturn.visible = phase == Phase.PlayersTurn
		match phase:
			Phase.PlayersMessage, Phase.SlimesMessage:
				$UI/outcomebox.show()
				$UI/outcomebox/Label.text = message
			_:
				$UI/outcomebox.hide()
		match phase:
			Phase.PlayersMessage:
				match last_player_action:
					PUNCH_MISS:
						$Arena/Enemy.setup([20,10],randi_range(30,50))
					PUNCH:
						$Arena/Enemy.setup([12,11,],5)
					MAGIC:
						$Arena/Enemy.setup([20,10],randi_range(30,50))
			Phase.PlayersTurn:
				$Arena/Enemy.setup([10,10,10,11,10,10,10,11,10,10,10,10,20,],25)
			Phase.SlimesTurn:
				$Arena/Enemy.setup([10])
			Phase.SlimesMessage:
				if slime_attack:
					$Arena/Enemy.setup([30,30,30,31,32,30,30,30,30,30,30,30,30,30,],4)
				else:
					$Arena/Enemy.setup([10])

func _physics_process(_delta: float) -> void:
	if phase_age < 9999: phase_age += 1
	if phase_age == 50 and len($Arena/Enemy.frames)>1:
		$Arena/Enemy.setup([10]) # no more animation.
	match phase:
		Phase.PlayersTurn:
			$UI/playerstats.show()
		Phase.PlayersMessage:
			if Pin.get_action_hit() and phase_age>3:
				set_phase(Phase.SlimesTurn)
		Phase.SlimesTurn:
			if last_player_action == LEAVE:
				set_phase(Phase.NoPlayer)
			elif phase_age > 30:
				if randf() < 0.5:
					slime_attack = true
					set_phase(Phase.SlimesMessage, " PURPLE1 strikes!")
					$Phit.play()
				else: phase_age -= 10
		Phase.SlimesMessage:
			if slime_attack:
				if phase_age > 10 and phase_age < 30:
					$UI/playerstats.visible = phase_age % 5 > 2
				elif phase_age > 30:
					$UI/outcomebox/Label.text = " PURPLE1 strikes!\n You lose 0 HP"
					$UI/playerstats.show()
			if Pin.get_action_hit() and phase_age>(45 if slime_attack else 15):
				if last_player_action == LEAVE:
					set_phase(Phase.NoPlayer)
				else:
					set_phase(Phase.PlayersTurn)

func perform_player_action(player_action) -> void:
	last_player_action = player_action
	match player_action:
		PUNCH:
			if randf() < 0.5:
				for i in range(4): ($V
					.spawn_exile_by_name("Hitstar",$Arena/fx)
					.setup(Vector2(50,50),i)
					)
				set_phase(Phase.PlayersMessage, " Hit PURPLE1!")
				$Cry.play()
			else:
				last_player_action = PUNCH_MISS
				set_phase(Phase.PlayersMessage, " Missed PURPLE1!")
				$Miss.play()
		MAGIC:
			set_phase(Phase.PlayersMessage, "Tried to MAGIC but\n no MP!")
			$NoMP.play()
		LEAVE:
			set_phase(Phase.PlayersMessage, " Left.")
			$Left.play()
			$combat_bgm.stop()
			#$gone_bgm.play()
