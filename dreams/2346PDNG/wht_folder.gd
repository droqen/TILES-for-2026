extends Node2D

func update_lookinatwhite(distance:int) -> void:
	show()
	for i in 4:
		get_node("%df" % i).visible = distance == i
