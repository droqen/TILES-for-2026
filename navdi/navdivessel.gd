@tool
extends Node2D
class_name NavdiVessel
@export var vessel_room_size : Vector2i = Vector2i(100, 100)
const GRID_PFB = preload("res://navdi/navdivesselgrid.gd")
var _grid : GRID_PFB
func _enter_tree() -> void:
	self._grid = GRID_PFB.new()
	self._grid.vessel = self
	#self._grid.owner = get_tree().root
	add_child(self._grid, false, Node.INTERNAL_MODE_BACK)

var exiled_maze : Maze
var exiles_by_name : Dictionary
var exiles_by_roomcoords : Dictionary

func _ready() -> void:
	if !Engine.is_editor_hint():
		for child in get_children():
			add_exile(child)
			remove_child(child)
func add_exile(x:Node) -> void:
	if x:
		exiles_by_name[x.name] = x
		if x is Maze:
			if exiled_maze == null:
				exiled_maze = x
			else:
				push_warning("Can't exile multiple mazes! Skipping maze %s" % x.name)
		if x is Node2D:
			@warning_ignore("integer_division")
			var roomcoords : Vector2i = (x as Node2D).position as Vector2i / vessel_room_size
			var a : Array = exiles_by_roomcoords.get(roomcoords, []) as Array
			a.append(x as Node2D)
			exiles_by_roomcoords.set(roomcoords, a)
	else:
		push_warning("Can't add null exile")
func get_maze() -> Maze:
	return exiled_maze
func get_exile_by_name(exile_name : String) -> Node:
	return exiles_by_name.get(exile_name, null) as Node
func get_exiles_by_roomcoords(roomcoords : String) -> Array:
	return exiles_by_roomcoords.get(roomcoords, []) as Array
