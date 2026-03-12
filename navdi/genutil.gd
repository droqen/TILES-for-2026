@tool
extends EditorScript
class_name NavdiGenUtil

func _run() -> void:
	print(gen_dreamnotes("test"))

static func gen_dreamnotes(dreamname:String) -> String:
	seed(dreamname.hash())
	var dreamnotes : String = (
"""
	Notes for dream '%s'
	created %s
	
	---
	
	Tarot card for this project:
	%s. %s
"""
		% [
			dreamname,
			gen_prettydate(),
			gen_az(), gen_simpletarot(),
		])
	randomize()
	return dreamnotes

const TAROT = ['the fool','the magician','the high priestess','the empress','the emperor','the hierophant','the lovers','the chariot','strength','the hermit','the wheel of fortune','justice','the hanged man','death','temperance','the devil','the tower','the star','the moon','the sun','judgement','the world','ace of coins','ace of cups','ace of swords','ace of wands','two of coins','two of cups','two of swords','two of wands','three of coins','three of cups','three of swords','three of wands','four of coins','four of cups','four of swords','four of wands','five of coins','five of cups','five of swords','five of wands','six of coins','six of cups','six of swords','six of wands','seven of coins','seven of cups','seven of swords','seven of wands','eight of coins','eight of cups','eight of swords','eight of wands','nine of coins','nine of cups','nine of swords','nine of wands','ten of coins','ten of cups','ten of swords','ten of wands','page of coins','page of cups','page of swords','page of wands','knight of coins','knight of cups','knight of swords','knight of wands','queen of coins','queen of cups','queen of swords','queen of wands','king of coins','king of cups','king of swords','king of wands']
const ALPHABET = 'qwertyuiopasdfghjklzxcvbnm'
const MONTHS = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December',]

static func gen_prettydate() -> String:
	var now = Time.get_datetime_dict_from_system()
	return "%d %s %d, at %02d:%02d" % [
		now.year, MONTHS[now.month-1], now.day, 
			# at
		now.hour, now.minute,
	]
static func gen_az() -> String:
	return ALPHABET[randi()%len(ALPHABET)]
static func gen_simpletarot() -> String:
	return TAROT[randi()%len(TAROT)]
