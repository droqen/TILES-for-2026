extends Node2D

class LineSet:
	var a : Vector2
	var bs : Array[Vector2]
	func draw(c:CanvasItem, amult:float):
		for i in range(3):
			c.draw_line(a,bs[i],Color(1,1,1, (0.8 - 0.3 * i)*amult ), 3)
			#c.draw_line(a,bs[i],Color(1,1,1,1), 6-i*2)

class Blib:
	var pos : Vector2
	var vel : Vector2
	var relationships : Array[Blib]
	var linesets : Array[LineSet] = []
	func _init(bounds:Rect2) -> void:
		pos.x = bounds.size.x*randf()
		pos.y = bounds.size.y*randf()
		vel = Vector2.RIGHT.rotated(PI*randf())
	func step(bounds:Rect2):
		if relationships:
			if randf() * pos.distance_squared_to(relationships[0].pos) < 100:
				pos.x = bounds.size.x*randf()
				pos.y = bounds.size.y*randf()
				vel = Vector2.RIGHT.rotated(PI*randf())
				#pos.x = bounds.size.x - pos.x + bounds.position.x
				#pos.y = bounds.size.y - pos.y + bounds.position.y
		pos += vel
		if pos.x < bounds.position.x: vel.x = abs(vel.x)
		if pos.y < bounds.position.y: vel.y = abs(vel.y)
		if pos.x > bounds.position.x + bounds.size.x: vel.x = -abs(vel.x)
		if pos.y > bounds.position.y + bounds.size.y: vel.y = -abs(vel.y)
		relationships.clear()
	func relate_to(b2:Blib):
		relationships.append(b2)
		relationships.sort_custom(func(a,b):
			return pos.distance_squared_to(a.pos)<pos.distance_squared_to(b.pos) # sort ascending - closest first
		)
	func draw(c:CanvasItem):
		var ls : LineSet = LineSet.new()
		ls.a = pos
		ls.bs = [
			relationships[0].pos,
			relationships[1].pos,
			relationships[2].pos,
		]
		linesets.push_front(ls)
		if len(linesets) > 20:
			linesets.pop_back()
		#c.draw_rect(Rect2(pos-Vector2(5,5),Vector2(10,10)), Color.RED)
		c.draw_circle(pos, 1.5, Color.WHITE, true)
		for i in range(len(linesets)):
			linesets[i].draw(c, 1.0 / (1.0 + i))
	func draw_to(c:CanvasItem, b2:Blib):
		if pos.x <= b2.pos.x:
			var dist : float = pos.distance_to(b2.pos)
			var width : float = 0.1
			if dist < 1000:
				width += 300.0 / (dist + 100)
			var col = Color.WHITE
			if width < 1: col.a = width
			c.draw_line(pos, b2.pos, col, max(1,width))

var blibs : Array[Blib] = []

func get_bordered_rect():
	var r = get_viewport_rect()
	r.position += Vector2(30,30)
	r.size -= Vector2(60,60)
	return r

func _ready() -> void:
	var viewport_rect = get_bordered_rect()
	for i in range(20):
		blibs.append(Blib.new(viewport_rect))

var redraw_delay : int = 0

func _physics_process(_delta: float) -> void:
	var viewport_rect = get_bordered_rect()
	for b in blibs: b.step(viewport_rect)
	#print(get_local_mouse_position())
	if redraw_delay > 0: redraw_delay -= 1
	else:
		queue_redraw()
		redraw_delay = 0

func _draw() -> void:
	var viewport_rect = get_viewport_rect()
	draw_rect(viewport_rect, Color.BLACK)
	for b in blibs:
		for b2 in blibs:
			if b != b2: b.relate_to(b2)
	for b in blibs:
		b.draw(self)
	#draw_rect(
		#Rect2(
			#get_local_mouse_position(),
			#Vector2(10,10)
		#)
		#,Color.RED
	#)
