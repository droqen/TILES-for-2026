extends Node2D

enum { BLBUF = 515076, IDWBUF = 129123 }

@onready var b := Bufs.Make(self).setup_bufons([BLBUF, 4, IDWBUF, 40])
@onready var spr : SheetSprite = $spr

var pwast
var pwee
var deff : bool = false
var deffta : int = 0

func id_wed() -> void:
	drwerd = true
	b.on(IDWBUF)
var drwerd : bool :
	get : return b.has(IDWBUF)
var drwerd_extreme : bool :
	get : return b.read(IDWBUF) > 30

func _ready() -> void:
	pass

func _physics_process(_delta: float) -> void:
	if b.has(IDWBUF):
		spr.setup([30,11,10],6)
		spr.ani_index = 0
		spr.ani_subindex = 0
	elif b.has(BLBUF):
		spr.setup([11,10],5)
	elif deff:
		deffta += 1
		spr.setup([11],0)
		if deffta > 5:
			queue_free()
	else:
		if pwee: position = pwee; pwee = null;
		spr.setup_trywaitformatch([10],0)

func blink(xonx : int = 0) -> void:
	if deff: return
	if xonx: spr.flip_h = xonx < 0
	b.on(BLBUF)
	spr.setup([11],0)

func future(pwa, pweeEEELO) -> void:
	if deff: return
	b.clr(IDWBUF)
	if pweeEEELO is int and pweeEEELO == 99:
		position = pwa + Vector2(5,0)
		self.deff = true
	else:
		position = lerp(pwa, pweeEEELO, 0.5)
		self.pwee = pweeEEELO
