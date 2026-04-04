extends Node2D

@onready var label : Label = $Label

signal advanced

enum { NOTHING, PRINTING, DONE_PRINTING, }
var state = NOTHING

var nohitbuf := 0
var blinkon := 0
var blinkoff := 0
var spacebuf := 0
var found_slowing_punctuation := false

func loop_until_advance(textmessage : String) -> void:
	label.text = textmessage
	label.visible_characters = 0
	state = PRINTING
	nohitbuf = 3;
	await advanced

func _physics_process(_delta: float) -> void:
	match state:
		PRINTING:
			if spacebuf > 0:
				spacebuf -= 1
			else:
				if label.text[label.visible_characters] in ['.',')','!','?']:
					found_slowing_punctuation = true
				if label.text[label.visible_characters] == ' ':
					spacebuf = 20 if found_slowing_punctuation else 5
					found_slowing_punctuation = false
				else:
					$speakbeep.stop()
					$speakbeep.play()
				label.visible_characters += 1
				
			if nohitbuf > 0: nohitbuf -= 1
			elif label.visible_ratio >= 1.0 or Pin.get_action_hit():
				state = DONE_PRINTING
				label.visible_characters = len(label.text) - 1
				blinkon = 1
		DONE_PRINTING:
			if blinkoff > 0:
				blinkoff -= 1
				if blinkoff <= 0:
					label.visible_characters = len(label.text) - 1
					blinkon = 50
			elif blinkon > 0:
				blinkon -= 1
			else:
				label.visible_ratio = 1.0
				blinkoff = 25
			if Pin.get_action_hit():
				label.text = ''
				state = NOTHING
				advanced.emit()
				$advance.play()
