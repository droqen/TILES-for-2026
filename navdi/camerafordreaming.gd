extends Camera2D
class_name CameraForDreaming

var realposition : Vector2
@export var pixelsnap : bool = false
@export var subpixelsnap : bool = true

@export var sloppiness : float = 0.5
@export var accsloppiness : float = 0.2
@export var sloppyfriction : float = 0.8
@export var unsloppy_flat_pos : float = 0.01
@export var unsloppy_flat_zoom : float = 0.003

@export var zoom_int_snap : bool = false
@export var zoom_minimum : float = 1.0
@export var view_padding_absolute : Vector2 = Vector2(10, 10)
@export var dreamview_rect : Rect2 = Rect2(0, 0, 100, 100)
var _last_known_dreamview_rect : Rect2
var _last_known_viewport_size : Vector2
var _last_known_viewport_size_padded : Vector2
var _target_pos : Vector2 = Vector2(50, 50)
var _target_zoom : float = 3.0
var velocity : Vector2
var zvelocity : float

func _ready() -> void:
	get_viewport().size_changed.connect(_force_update_viewport_size)
	_force_update_viewport_size()
	_force_update_viewport_size.call_deferred()
func _force_update_viewport_size() -> void:
	_last_known_viewport_size = get_viewport_rect().size
	_last_known_viewport_size_padded = _last_known_viewport_size - view_padding_absolute * 2
	_force_update_targets()
func _force_update_targets() -> void:
	_last_known_dreamview_rect = dreamview_rect
	#_target_zoom = max(zoom_minimum,
		#min()
	#)
	var dreamsize : Vector2 = dreamview_rect.size
	_target_pos = dreamview_rect.position + dreamsize * 0.5
	_target_zoom = max(zoom_minimum,min(
		_last_known_viewport_size_padded.x / dreamsize.x,
		_last_known_viewport_size_padded.y / dreamsize.y
	))
	if zoom_int_snap: _target_zoom = int(_target_zoom)

func set_dreamview_size(size:Vector2) -> void:
	if dreamview_rect.size != size:
		var focus : Vector2 = dreamview_rect.get_center()
		dreamview_rect.size = size
		set_dreamview_focus(focus)
func set_dreamview_focus(focus:Vector2) -> void:
	dreamview_rect.position = focus - dreamview_rect.size * 0.5

func snap_to_target() -> void:
	_force_update_targets()
	realposition = _target_pos; velocity *= 0;
	zoom = Vector2.ONE * _target_zoom; zvelocity *= 0;
	
	if pixelsnap: position = Vector2(Vector2i(realposition))
	elif subpixelsnap: position = Vector2(Vector2i(realposition*zoom.x))/zoom.x
	else: position = realposition
	
func _physics_process(_delta: float) -> void:
	if _last_known_dreamview_rect != dreamview_rect:
		_force_update_targets()
	
	var vel2 : Vector2 = (_target_pos - realposition) * sloppiness
	velocity = lerp(velocity,vel2,accsloppiness) * (1-sloppyfriction)
	realposition += velocity
	realposition += (_target_pos - realposition).limit_length(unsloppy_flat_pos)
	
	if pixelsnap: position = Vector2(Vector2i(realposition))
	elif subpixelsnap: position = Vector2(Vector2i(realposition*zoom.x))/zoom.x
	else: position = realposition
	
	var zvel2 : float = (_target_zoom - zoom.x) * sloppiness
	zvelocity = lerp(zvelocity,zvel2,accsloppiness) * (1-sloppyfriction)
	zoom.x += zvelocity
	zoom.x = move_toward(zoom.x, _target_zoom, unsloppy_flat_zoom)
	zoom.y = zoom.x
