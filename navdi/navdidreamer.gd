extends Node
class_name NavdiDreamer

var initialized : bool = false
var dream_stack : Array[NavdiDream] = []
var dream_depth : int = -1

var _memory_stack : Array[Dictionary]

func w(k,v,d:NavdiDream=null):
	prints("w",k,v,d)
	if dream_depth < 0:
		push_error("dream depth is -1, meaning Dreamer has not been initiated - w (write) does not work")
	elif d == null:
		_memory_stack[dream_depth][k] = v
	else:
		var i = dream_stack.find(d)
		print(i)
		if i >= 0:
			_memory_stack[i][k] = v
		else:
			push_error("dream %s is undreamt - w (write) does not work on dreams not currently in the dream stack")
func r(k,d=null):
	print("r",k)
	for i in range(0,dream_depth+1):
		if _memory_stack[i].has(k):
			prints("hello i has:", _memory_stack[i][k])
			return _memory_stack[i][k]
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
			print(dream_stack)
			print(dream_depth)
			print(dream_stack[dream_depth])
			push_error("goto current dream packed failed - current dream is null")
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
