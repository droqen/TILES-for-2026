extends Node
class_name NavdiViewer
const GROUP : StringName = &"ViewerGrp"
const VIEWRECTGROUPNAME : StringName = &"ViewRectGrp"

var _smoothness : float = 1.0
@export_range(-10, 10, 0.1) var smoothness : float :
	get : return _smoothness
	set (v) :
		_smoothness = v
		view_shader.set_shader_parameter("smoothness", v)
var following_viewrect:NavdiViewRect = null
var view_shader : ShaderMaterial :
	get : return $ViewShaderLayer/ViewShaderRect.material as ShaderMaterial

static func follow(r:NavdiViewRect) -> void:
	var viewer:NavdiViewer = r.get_tree(
	).get_first_node_in_group(GROUP)
	if viewer: viewer._follow(r)
func _follow(r:NavdiViewRect) -> void:
	if following_viewrect != r:
		if following_viewrect:
			close_eyes()
			following_viewrect.moved.disconnect(update_following)
			following_viewrect.tree_exiting.disconnect(close_eyes)
			following_viewrect = null
		following_viewrect = r
		if is_instance_valid(following_viewrect):
			following_viewrect.moved.connect(update_following)
			following_viewrect.tree_exiting.connect(close_eyes)
	if is_instance_valid(following_viewrect):
		update_following()
	else:
		close_eyes()

func _ready() -> void:
	add_to_group(GROUP)

func _physics_process(_delta: float) -> void:
	if is_instance_valid(following_viewrect):
		_follow(following_viewrect)
	elif following_viewrect:
		_follow(null)

func update_following() -> void:
	$ViewCamera.position = following_viewrect.position;
	view_shader.set_shader_parameter(
		"dreamsize", following_viewrect.size)
	view_shader.set_shader_parameter(
		"zoom", max(1,calculate_fitscale(
			get_viewport().get_visible_rect().size*0.75,
			following_viewrect.size
		))
	)

func close_eyes() -> void:
	view_shader.set_shader_parameter("dreamsize", Vector2(0,0))

func calculate_fitscale(pondsize:Vector2,fishsize:Vector2) -> float:
	#print( min(pondsize.x/fishsize.x,pondsize.y/fishsize.y,) )
	return min(pondsize.x/fishsize.x,pondsize.y/fishsize.y,)
