@tool
extends Node2D

@export var rectsize : float
@export var rectcol : Color
@export var rectthick : int

var _animating := false
var _animating_dir := 1
var _animprogress := 0.0

func animate_fwd() -> void:
	_animating = true
	_animating_dir = 1
	_animprogress = 0.0
	rectsize = 7.5
	rectthick = 5
func animate_bkwd() -> void:
	animate_fwd()
	_animating_dir = -1
	rectsize = 57.5

func _physics_process(_delta: float) -> void:
	if _animating:
		if _animprogress < 1.0:
			_animprogress += 1.0
		else:
			#_animprogress = 0.0
			#if _animprogress >= 1.0: _animating = false; _animprogress = 1.0;
			#var aroot = pow(_animprogress,1.0)
			#rectthick = round(5)
			#rectsize = round(lerp(10,60,aroot))
			queue_redraw()
			show()
			#_animprogress += 0.05
			rectsize += 5.0 * _animating_dir
			if rectsize <= 7.5: _animating = false; hide();
			if rectsize >= 62.5: _animating = false; hide();
	else:
		hide()

func _draw() -> void:
	draw_line(
		Vector2(-60,rectsize),Vector2(60,rectsize),
		rectcol,rectthick
	)
	draw_line(
		Vector2(-60,-rectsize),Vector2(60,-rectsize),
		rectcol,rectthick
	)
	#draw_rect(Rect2(-200,-rectsize,400,rectsize+rectsize),rectcol,false,rectthick)
