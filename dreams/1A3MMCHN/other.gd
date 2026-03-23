extends Area2D

var killed := false
var dying := 0
func try_kill() -> bool:
	if not killed:
		killed = true
		return true
	else:
		return false
func _physics_process(_delta: float) -> void:
	if killed:
		dying += 1
		if dying < 2: $spr.setup([19])
		elif dying < 14: $spr.setup([18,28],3)
		elif dying < 24: $spr.setup([19])
		elif dying < 24+4*1: $spr.setup([29])
		elif dying < 24+4*2: $spr.setup([39])
		elif dying < 24+4*3: $spr.setup([49])
		elif dying < 24+4*4: $spr.setup([59])
		else: queue_free()
