extends Node2D

@export var is_active_entity : bool = false
@export var full_response : String = ''

class BodyPart:
	var part:Node2D
	var startpos:Vector2
	var fliplikely:float = 0.0
	var unfliplikely:float = 0.0
	func _init(_part:Node2D) -> void:
		self.part = _part
		self.startpos = _part.position
	func part_update() -> void:
		if randf() < 0.005:
			part.position.x = clamp(part.position.x + randi_range(-1,1), startpos.x-1, startpos.x+1)
		if randf() < 0.005:
			part.position.y = clamp(part.position.y + randi_range(-1,1), startpos.y-1, startpos.y+1)
		if fliplikely and not part.flip_h and randf() < fliplikely: part.flip_h = true
		if part.flip_h and randf() < unfliplikely: part.flip_h = false
	func setup_flipunflip(f,uf):
		fliplikely = f; unfliplikely = uf; return self

var parts : Array[BodyPart]
@onready var startpos := position
func _ready() -> void:
	parts = [
		BodyPart.new($legs).setup_flipunflip(0.01,0.02),
		BodyPart.new($arms),
		BodyPart.new($head).setup_flipunflip(0.005,0.15),
		BodyPart.new($shoulder),
	]

func _physics_process(_delta: float) -> void:
	for part in parts: part.part_update()
	if randf() < 0.01:
		position.x = clamp(position.x + randi_range(-1,1), startpos.x - 2, startpos.x + 2)
	if randf() < 0.01:
		position.y = clamp(position.y + randi_range(-1,1), startpos.y - 2, startpos.y + 2)
