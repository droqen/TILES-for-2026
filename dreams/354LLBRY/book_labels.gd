extends Node2D

@onready var v : NavdiVessel = $"../V"

class Line extends RefCounted:
	var llabel = null
	var word : String
	var wordletters : int
	var wordprogress : float
	var base_delay_frames : int
	var delayframes : int
	var done : bool = false
	var erasing : bool = false
	func _init(_llabel,pos:Vector2,_word:String,i:int):
		_llabel.position = pos
		self.llabel = _llabel
		_llabel.text = '' # none
		self.word = _word
		self.wordletters = 0
		self.wordprogress = 0.0
		self.base_delay_frames = i * 12
		self.delayframes = self.base_delay_frames
	func begin_showing() -> void:
		if self.wordletters < len(self.word): done = false; erasing = false;
	func begin_erasing() -> void:
		if self.wordletters > 0: done = false; erasing = true;
	func update() -> void:
		if erasing and done:
			if delayframes < base_delay_frames: delayframes += 1
		elif delayframes > 0: delayframes -= 1
		elif not done:
			if erasing:
				wordprogress -= 0.3
				if wordprogress <= 0:
					wordprogress += 1
					wordletters -= 1
					if wordletters <= 0: llabel.text = ''; wordletters = 0; done = true;
					else: llabel.text = word.substr(0, wordletters)
			else:
				wordprogress += 0.2
				if wordprogress >= 1:
					wordprogress -= 1
					wordletters += 1
					if wordletters >= len(word): llabel.text = word; done = true
					else: llabel.text = word.substr(0,wordletters)

var book
var lines : Array[Line]
var erasing : bool = false

func show_book(book_to_show,pos:Vector2) -> void:
	if book_to_show == book and pos == position:
		for line in self.lines:
			line.begin_showing()
	else:
		book = book_to_show
		position = pos
		rotation = book.ccwrot * PI * 0.5
		var x = 0
		var y = -5 * floor(len(book.words)*0.5)
		for c in get_children(): c.queue_free() # bye
		self.lines.clear()
		for i in range(len(book.words)):
			self.lines.append(Line.new(
				v.spawn_exile_by_name("LineLabel",self),
				Vector2(x+book.woffsets[i]*5,y+5*i),
				book.words[i],
				i
			))
func hide_book() -> void:
	for line in self.lines:
		line.begin_erasing()

func _physics_process(_delta: float) -> void:
	for line in self.lines:
		line.update()
