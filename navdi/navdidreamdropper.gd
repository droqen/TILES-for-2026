extends Node
class_name NavdiDreamDropper

func _ready() -> void:
	print("hello")
	get_window().files_dropped.connect(_on_files_dropped)

func _on_files_dropped(files:PackedStringArray) -> void:
	print("files dropped")
	print(files)
	for file in files:
		if file.ends_with(".pck"):
			Dreamer.load_packed_dream(file)
			#var success = ProjectSettings.load_resource_pack(file)
			#if success:
				#print("success! (dreamdropper)")
				#Dreamer.wake_to(Dreamer.dream_stack[0])
				#Dreamer.reset()
			#else:
				#print("failure! (dreamdropper)")
