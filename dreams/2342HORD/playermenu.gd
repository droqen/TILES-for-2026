extends Node2D

signal confirmed_final_action(action_array : Array[String])

const GHOSTLETTERS = ["A", "B", "C", "D"]
var mindex := 1
@onready var menu1 : Node2D = $Menu1
@onready var menu2 : Node2D = $Menu2
@onready var menu1pos : Vector2 = menu1.position
@onready var menu2pos : Vector2 = menu2.position
@onready var menu1lbl : Label = menu1.get_node("Label")
@onready var menu2lbl : Label = menu2.get_node("Label")

var last_action : Array[String] = []

var menu : NavdiMenuLevel = NavdiMenuLevel.new("MainBattleMenu",
	[
		NavdiMenuLevel.new("CUT", GHOSTLETTERS),
		"DODGE",
		"WAIT",
		"WISH",
		"LEAVE",
	]
)

var active_menu : NavdiMenuLevel = menu

func update_control() -> void:
	menu1.show(); menu1.position.x = lerp(menu1.position.x, menu1pos.x, 0.2)
	if mindex == 2:
		menu2.show(); menu2.position.x = lerp(menu2.position.x, menu2pos.x, 0.2)
	elif menu2.visible:
		menu2.position.x += 1
		if menu2.position.x >= menu2pos.x + 5:
			menu2.hide()
	var dpad_tap := Pin.get_dpad_tap()
	var dy = dpad_tap.y
	if dy: active_menu.try_move(dy)
	if Pin.get_action_hit():
		var action = active_menu.menuitems[active_menu.selectionid]
		if action is NavdiMenuLevel:
			mindex += 1 # depth increase
			active_menu = action as NavdiMenuLevel
			active_menu.selectionid = 0
		else:
			last_action = [action as String]
			if mindex > 1:
				last_action.push_front(active_menu.identifier)
			confirmed_final_action.emit(last_action)
	if Pin.get_cancel_hit() or dpad_tap.x < 0:
		if mindex > 1:
			mindex = 1
			active_menu = menu
		# else: hide for a moment?

	menu1lbl.text = ''
	for i in len(menu.menuitems):
		menu1lbl.text += ">" if i == menu.selectionid else " "
		var item = menu.menuitems[i]
		menu1lbl.text += (item if item is String else item.identifier) + '\n'
	if active_menu != menu:
		menu2lbl.text = ''
		for i in len(active_menu.menuitems):
			menu2lbl.text += ">" if i == active_menu.selectionid else " "
			var item = active_menu.menuitems[i]
			menu2lbl.text += item + '\n'

func update_reset() -> void:
	for mmm in [[menu1,menu1pos],[menu2,menu2pos]]:
		var m = mmm[0]
		var mposx = mmm[1].x
		if m.position.x < mposx + 3:
			m.position.x += 2
		else:
			m.position.x = mposx + 5
			m.hide()
	if active_menu != menu:
		active_menu = menu
		mindex = 1
	menu.selectionid = 0
