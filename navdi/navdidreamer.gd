extends Node
class_name NavdiDreamer

var dream_stack : Array[NavdiDream] = []
var dream_depth : int = -1

var _memory_stack : Array[Dictionary]

func w(k,v,d:NavdiDream=null):
	#prints("w",k,v,d)
	navdilog(k,str(v))
	if dream_depth < 0:
		push_error("dream depth is -1, meaning Dreamer has not been initiated - w (write) does not work")
	elif d == null:
		_memory_stack[dream_depth][k] = v
	else:
		var i = dream_stack.find(d)
		#print(i)
		if i >= 0:
			_memory_stack[i][k] = v
		else:
			push_error("dream %s is undreamt - w (write) does not work on dreams not currently in the dream stack")
func r(k,d=null):
	#print("r",k)
	for i in range(0,dream_depth+1):
		if _memory_stack[i].has(k):
			#prints("hello i has:", _memory_stack[i][k])
			navdilog(k, str(_memory_stack[i][k]) + " (read)")
			return _memory_stack[i][k]
	navdilog(k,str(d) + " (default)")
	return d
func first(k)->bool:
	if r(k)==null: w(k,1); return true;
	return false # else<

func _goto_current_dream_packed():
	if dream_depth < 0:
		push_error("goto current dream packed failed - dream depth < 0 - quitting")
		get_tree().quit(0)
	else:
		var d : NavdiDream = dream_stack[dream_depth]
		if d == null:
			#print(dream_stack)
			#print(dream_depth)
			#print(dream_stack[dream_depth])
			push_error("goto current dream packed failed - current dream is null.")
		elif d.packed_scene == null:
			push_error("goto current dream packed failed - dream %s has no packed scene" % dream_stack[dream_depth])
		else:
			var ps : PackedScene = d.packed_scene
			await get_tree().process_frame # wait 1 frame... in the long run we could be waiting longer than this
			var err = get_tree().change_scene_to_packed(ps)
			if err != OK:
				push_error("failed to change scene to packed %s of dream %s : reason %s" % [ps, d , err])

func dream(d:NavdiDream) -> void:
	if d in dream_stack:
		push_error("already inside dream %s" % d)
	else:
		dream_stack.append(d)
		_memory_stack.append(Dictionary())
		dream_depth += 1
		_goto_current_dream_packed()

func dreamfresh(d:NavdiDream) -> void:
	dream_stack=[d]
	_memory_stack=[Dictionary()]
	dream_depth=0
	_goto_current_dream_packed()

func reset():
	_goto_current_dream_packed()

func wake() -> void:
	dream_stack.pop_back()
	_memory_stack.pop_back()
	dream_depth -= 1
	if dream_depth >= 0:
		_goto_current_dream_packed()
	else:
		# save memories?
		get_tree().quit(0) # awake

func wake_to(d:NavdiDream):
	var i = dream_stack.find(d)
	if i >= 0:
		dream_stack = dream_stack.slice(0, i + 1)
		dream_depth = i
		_goto_current_dream_packed()
	else:
		push_error("can't wake up to undreamt dream %s" % d); return false;

func spawn(node_or_packed, parent : Node = null) -> HandledNodeSpawn:
	var hns = HandledNodeSpawn.new(node_or_packed)
	if !parent: parent = get_tree().current_scene
	if hns.n and parent:
		_add_to_and_own.call_deferred(hns.n, parent)
	else:
		push_error("spawning %s to parent %s failed"
			% [node_or_packed, parent])
	return hns

func navdilog(key:String,value:String) -> void:
	NavdiViewer.navdilog(self,key,value)

func _add_to_and_own(ch:Node, par:Node) -> void:
	par.add_child(ch)
	ch.owner = par.owner if par.owner else par

func load_packed_dream(dream_pck_filepath: String) -> void:
	#print("*** load packed dream (%s)" % dream_pck_filepath)
	if dream_pck_filepath.ends_with(".pck"):
		var dream_broken := (dream_pck_filepath
			.rsplit("/",false,1)[-1]
			.split('.',false)
		)
		var extracted_dream_name : String = dream_broken[-1]
		if len(dream_broken) > 1 and dream_broken[-1] == "pck":
			extracted_dream_name = dream_broken[-2]
		#print("*** about to load resource pack..")
		var _success = ProjectSettings.load_resource_pack(dream_pck_filepath, true)
		#print("*** load resource pack success? ",_success)
		var expected_dream_file_path = "res://dreams/%s/%s_Dream.tres" % [
			extracted_dream_name,
			extracted_dream_name]
		#print("*** expected path: ",expected_dream_file_path)
		var expected_dream = ResourceLoader.load(expected_dream_file_path, "NavdiDream", ResourceLoader.CACHE_MODE_REPLACE_DEEP)
		if expected_dream:
			if expected_dream is NavdiDream:
				dreamfresh(expected_dream)
				navdilog("lpck", "Dreaming... %s" % extracted_dream_name)
			else:
				navdilog("lpck", "Corrupted dream found at %s" % expected_dream_file_path)
		else:
			navdilog("lpck", "Expected dream not found at %s" % expected_dream_file_path)
			#dream()

class HandledNodeSpawn:
	var n : Node
	func _init(obj_or_packed):
		var obj = obj_or_packed
		if obj is PackedScene:
			obj = obj_or_packed.instantiate()
		if obj is Node:
			n = obj # TODO: to duplicate or not to duplicate...
		else:
			n = null # remain null
			push_error(
				"HandledNodeSpawn n failed ; "+
					"%s (%s) is not Node or PackedScene"
				% [obj, obj_or_packed] )
	func setup_pos(pos:Vector2) -> HandledNodeSpawn:
		if n and n is Node2D:
			n.position = pos
		else:
			push_error("setup_pos failed ; n %s is not Node2D" % n)
		return self
	func setup_varvals(varvals:Array) -> HandledNodeSpawn:
		if n and n is Object:
			for i in range(0, len(varvals)-1, 2):
				n[varvals[i]] = varvals[i+1]
		else:
			push_error("setup_varvals failed ; n %s is not Object" % n)
		return self

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if (event as InputEventKey).keycode == KEY_ESCAPE:
			if OS.has_feature("editor"):
				wake()
