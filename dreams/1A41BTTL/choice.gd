extends Label

signal chose_punch
signal chose_magic
signal chose_leave

var choicemenu : NavdiMenuLevel

var keyrepeatbuf := 0

func _ready() -> void:
	choicemenu = NavdiMenuLevel.new("Choices",
		["PUNCH", "MAGIC", "LEAVE", ]
	)
	reprint()

func _physics_process(_delta: float) -> void:
	if not get_parent().visible:
		keyrepeatbuf = -1
		if choicemenu.selectionid:
			choicemenu.selectionid = 0
			reprint()
	else:
		var dy := Pin.get_dpad().y
		#var dy_tap := Pin.get_dpad_tap().y
		if Pin.get_action_hit() and keyrepeatbuf==0:
			match choicemenu.menuitems[choicemenu.selectionid]:
				"PUNCH":
					chose_punch.emit()
					get_parent().hide()
				"MAGIC":
					chose_magic.emit()
					get_parent().hide()
				"LEAVE":
					chose_leave.emit()
					get_parent().hide()
		if dy==0: keyrepeatbuf=0;
		elif keyrepeatbuf>0: keyrepeatbuf-=1
		elif keyrepeatbuf==0:
			keyrepeatbuf = 7
			if Pin.get_dpad_tap().y: keyrepeatbuf = 26
			if choicemenu.try_move(dy):
				reprint()

func reprint() -> void:
	text = ""
	for i in len(choicemenu.menuitems):
		text += "%s%s\n" % [
			">" if i == choicemenu.selectionid else " ",
			choicemenu.menuitems[i],
		]
