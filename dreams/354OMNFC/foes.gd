extends Node2D

signal fizzingchanged(prev,curre)

var childcount := 0
var fizzingchildren := 0
var playergone := false

func _physics_process(_delta: float) -> void:
	var prevchildcount := childcount
	var prevfizzing := fizzingchildren
	childcount = get_child_count()
	fizzingchildren = 0
	for i in childcount:
		var a = get_child(i)
		if a.fizzing: fizzingchildren += 1
		for j in range(i+1,childcount):
			var b = get_child(j)
			a.process_foe_interaction(b)
			if not playergone: b.process_foe_interaction(a)
	if prevfizzing != fizzingchildren:
		fizzingchanged.emit(prevfizzing, fizzingchildren)

func get_living_child_count() -> int:
	return childcount - fizzingchildren

func queue_free_if_not_last(foe) -> void:
	if childcount > 1:
		foe.queue_free()
		childcount -= 1
