@tool
extends EditorPlugin

const DREAMWEAVER_MESSAGE = &"Create Dream from pyxel"

var dialog : EditorFileDialog

func _enter_tree() -> void:
	dialog = EditorFileDialog.new()
	dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
	dialog.title = "Create Dream from pyxel"
	dialog.filters = ["*.pyxel"]
	dialog.current_dir = "res://dreams/"
	get_editor_interface().get_base_control().add_child(dialog)
	add_tool_menu_item(DREAMWEAVER_MESSAGE, _on_menu_pressed)
	dialog.file_selected.connect(_on_pyxel_selected)

func _exit_tree() -> void:
	if dialog:
		remove_tool_menu_item(DREAMWEAVER_MESSAGE)
		dialog.queue_free() # disconnect incl.
	
func _on_menu_pressed() -> void:
	dialog.popup_centered(Vector2i(800,600))

func _on_pyxel_selected(path:String) -> void:
	if path.ends_with(".pyxel"):
		var parent_dir_file = path.rsplit("/",false,2)
		var dir = parent_dir_file[0] + "/" + parent_dir_file[1] + "/"
		var dirname = parent_dir_file[1]
		var filename_fileext = parent_dir_file[2].rsplit(".",false,1)
		var filename = filename_fileext[0]
		
		var pyxel_resource = ResourceLoader.load(path)
		
		var SHEET_PATHNAME = dir+filename+"_sheet.tres"
		var TILES_PATHNAME = dir+filename+"_tiles.tres"
		var SCENE_PATHNAME = dir+dirname+"_scene.tscn"
		var DREAM_PATHNAME = dir+dirname+"_Dream.tres"
		
		var err
		err = save_if_new(SHEET_PATHNAME, func():
			var new_sheet = Sheet.new()
			new_sheet.texture = pyxel_resource
			new_sheet.hframes = 10
			new_sheet.vframes = 10
			return new_sheet)
		err = save_if_new(TILES_PATHNAME, func():
			var new_atlas = TileSetAtlasSource.new()
			new_atlas.texture = pyxel_resource
			new_atlas.texture_region_size = Vector2i(10,10)
			var grid_size = new_atlas.get_atlas_grid_size()
			if grid_size != Vector2i(10,10):
				push_warning("atlas is not 10x10 tiles; ",pyxel_resource," should be 100x100 and it's not.")
			for y in range(grid_size.y):
				for x in range(grid_size.x):
					new_atlas.create_tile(Vector2i(x,y))
			var new_tiles = TileSet.new()
			new_tiles.tile_size = Vector2i(10,10)
			new_tiles.add_physics_layer(0)
			new_tiles.set_physics_layer_collision_layer(0,1)
			new_tiles.add_source(new_atlas)
			return new_tiles)
		err = save_if_new(SCENE_PATHNAME, func():
			var node = Node2D.new(); node.name = dirname
			var maze = Maze.new(); maze.name = "Maze"
			maze.tile_set = ResourceLoader.load(TILES_PATHNAME)
			for x in range(10):for y in range(10):
				maze.set_cell_tid(Vector2i(x,y),randi()%3-1)
			var spr = SheetSprite.new(); spr.name = "Spr"
			spr.sheet = ResourceLoader.load(SHEET_PATHNAME)
			spr.frames = [10,11]
			spr.ani_period = 10
			spr.position = Vector2(50,50)
			spr.playing = true
			var view = NavdiViewRect.new(); view.name = "View"
			view.size = Vector2i(100, 100)
			
			node.add_child(maze); maze.owner = node;
			node.add_child( spr);  spr.owner = node;
			node.add_child(view); view.owner = node;
			
			var new_scene = PackedScene.new()
			var result = new_scene.pack(node)
			if result != OK:
				push_error("SCENE CREATION FAILED err ",result)
			return new_scene)
		
		err = save_if_new(DREAM_PATHNAME,func():
			var new_dream = NavdiDream.new()
			new_dream.packed_scene = ResourceLoader.load(SCENE_PATHNAME)
			return new_dream)
	else:
		push_error("dreamweaver cannot use non-pyxel file: ",path)
	
func save_if_new(fullfilepath:String, generate:Callable) -> Error:
	if FileAccess.file_exists(fullfilepath):
		#push_warning("File already exists at ",fullfilepath)
		return Error.ERR_ALREADY_EXISTS
	else:
		ResourceSaver.save(generate.call(),fullfilepath)
		return OK
