extends Node
class_name NavdiDreamDropper

func _ready() -> void:
	#print("dropper setup success")
	get_window().files_dropped.connect(_on_files_dropped)
	var ecb = JavaScriptBridge.create_callback(_example_callback)
	# TODO: pass this callback to javascript! via  some object:
	var link = JavaScriptBridge.get_interface("navdilink")
	if ecb and link:
		#print("link: ",link)
		#link.testCallback(ecb);
		#print("ecb: ",ecb)
		link.setDropCallback(ecb);

func _example_callback(a) -> void:
	Dreamer.navdilog("dropper","example callback received! %d" % randi())
	print(a)

func _on_files_dropped(files:PackedStringArray) -> void:
	var delay : float = 1.0
	for file in files:
		if file.ends_with(".pck"):
			Dreamer.load_packed_dream(file)
			await get_tree().create_timer(randf_range(0.5,1.5)*delay).timeout
			delay *= 0.8
			#var success = ProjectSettings.load_resource_pack(file)
			#if success:
				#print("success! (dreamdropper)")
				#Dreamer.wake_to(Dreamer.dream_stack[0])
				#Dreamer.reset()
			#else:
				#print("failure! (dreamdropper)")
