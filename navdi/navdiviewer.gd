extends Node
class_name NavdiViewer
const VIEWRECTGROUPNAME : StringName = &"ViewRectGroupName"

var _initialized_viewrect = null

func _physics_process(_delta: float) -> void:
	var viewrect : Control = get_tree().get_first_node_in_group(VIEWRECTGROUPNAME)
	if viewrect:
		if _initialized_viewrect != viewrect:
			if is_instance_valid(_initialized_viewrect):
				_initialized_viewrect.tree_exiting.disconnect(close_eyes)
			_initialized_viewrect = viewrect
			viewrect.tree_exiting.connect(close_eyes)
		$ViewShaderLayer/ViewCamera.position = viewrect.position;
		$ViewShaderLayer/ViewShaderRect.set_instance_shader_parameter("dreamsize", viewrect.size)
		$ViewShaderLayer/ViewShaderRect.set_instance_shader_parameter("zoom",
		calculate_fitscale(get_viewport().get_visible_rect().size*0.9,viewrect.size)
		)
	else:
		close_eyes()

func close_eyes() -> void:
	$ViewShaderLayer/ViewShaderRect.set_instance_shader_parameter("dreamsize", Vector2(0,0))

func calculate_fitscale(pondsize:Vector2,fishsize:Vector2) -> float:
	return min(pondsize.x/fishsize.x,pondsize.y/fishsize.y,)
