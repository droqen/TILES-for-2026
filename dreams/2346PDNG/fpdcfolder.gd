extends Node2D

var folder_tiles : Dictionary = {}
func _ready() -> void:
	for f in 3+1:
		for x in 3+1:
			if x == 0:
				var t = get_node_or_null("%df" % f)
				if t : folder_tiles.set(Vector2i(0,f), t)
			else:
				for d in [-1,1]:
					var t = get_node_or_null("%df%s%dx" % [f,'-'if d<0 else'+',x])
					if t : folder_tiles.set(Vector2i(x*d,f), t)

func render34(solids34:Array[Vector2i]) -> void:
	for t in folder_tiles:
		folder_tiles[t].visible = t in solids34

var turnanimbuf := 3

func _physics_process(_delta: float) -> void:
	if position.x:
		if turnanimbuf > 0:
			turnanimbuf -= 1
		else:
			position.x = move_toward(position.x, 0, 5)
			turnanimbuf = 3

func animate_turn(turndir:int) -> void:
	position.x = turndir * 10
	turnanimbuf = 3
