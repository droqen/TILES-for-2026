extends Node2D

enum { BLBUF = 515076 }

@onready var b := Bufs.Make(self).setup_bufons([BLBUF, 4])
@onready var spr : SheetSprite = $spr

func _ready() -> void:
	pass

func _physics_process(_delta: float) -> void:
	if b.has(BLBUF):
		spr.setup([11],0)
	else:
		spr.setup([10],0)

func blink(xonx : int) -> void:
	if xonx: spr.flip_h = xonx < 0
	b.on(BLBUF)
	spr.setup([11],0)
