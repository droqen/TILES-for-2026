extends Node2D

# ensure is same as in battle.gd
enum {
	PA_greet, PA_smalltalk, PA_leave, PA_points, PA_points_lots, PA_wait,
}

@onready var menu : NavdiMenuLevel = NavdiMenuLevel.new("pick_menu",[
	[PA_greet,      "GREET\nJALLET"],
	[PA_smalltalk,  "MAKE SMALL\nTALK WITH\nJALLET"],
	[PA_leave,      "TELL\nJALLET TO\nLEAVE"],
	[PA_points,     "ASK JALLET\nFOR A FEW\nPOINTS"],
	[PA_points_lots,"ASK JALLET\nFOR LOTS\nOF POINTS"],
	[PA_wait,       "WAIT FOR\nJALLET TO\nSPEAK"],
], false)

@onready var startpos := position
var _is_awaited := false
signal selected_pa(pa)
func loop_until_select_player_action():
	show()
	_is_awaited = true
	var pa_chosen = await selected_pa
	$picked.play()
	_is_awaited = false
	hide()
	position = startpos
	return pa_chosen

func reprint() -> void:
	$Content.text = menu.menuitems[menu.selectionid][1]
	$ColorRect/LeaveSQuare.visible = menu.menuitems[menu.selectionid][0] == PA_leave
	$ArrowLeft.visible = menu.selectionid > 0
	$ArrowRight.visible = menu.selectionid + 1 < len(menu.menuitems)

func _ready() -> void:
	reprint()

func _physics_process(_delta: float) -> void:
	if _is_awaited:
		var dx := Pin.get_dpad_tap().x
		if dx:
			if menu.try_move(dx):
				position.x = startpos.x + 5 * dx
				reprint()
				if dx > 0:
					$yesmoveR.play()
				if dx < 0:
					$yesmoveL.play()
			else:
				position.x = startpos.x + 2 * dx
				$nomove.play()
		if abs(position.x-startpos.x)>0.1:
			position.x = lerp(position.x, startpos.x, 0.2)
		else:
			position = startpos
		if Pin.get_action_hit():
			selected_pa.emit(menu.menuitems[menu.selectionid][0])
	
