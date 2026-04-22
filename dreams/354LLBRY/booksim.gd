extends Node

@export var maze : Maze

class BookObj extends RefCounted :
	signal moved_from (from_cell : Vector2i)
	var maze : Maze
	var cell : Vector2i
	var tid : int
	var dirty : bool = true # we all start dirty
	var dirtywaiting : int = 0
	var deleted : bool = false
	var vy : int = 0
	var vysubpixel : int = 0
	var ccwrot : int = 0
	var words : PackedStringArray = "pose questions and body answers.".split(' ')
	var woffsets : Array[int] = [-2,-5,-1,-1,-3]
	func _init(newmaze : Maze, newcell : Vector2i, _seed : int, strings) -> void:
		maze = newmaze
		cell = newcell
		tid = BOOKS[randi()%4]
		_register()
		words = strings
		woffsets = []
		var maxlen = 0
		for word in words: maxlen = max(maxlen, len(word))
		var woffset_base : int = -floor(maxlen*0.5)
		for word in words: woffsets.append(woffset_base)
	
	func update() -> void:
		if dirty:
			vy += 1
			vysubpixel += vy
			if vysubpixel > 10:
				vysubpixel = 0
				if not try_move(Vector2i(0,1)):
					if dirtywaiting == 0: randomizespr()
					dirtywaiting += 1
					if dirtywaiting < 2 or randi() % dirtywaiting < 2:
						pass
					elif randf() < 0.5:
						dirty = false # no diagonal
					else:
						var mindx : int = -1
						if cell.x <= 2 and cell.y >= 6: mindx = 0
						if not try_move(Vector2i(randi_range(mindx,1),1)):
							dirty = false
						else:
							dirtywaiting = 0
				else:
					dirtywaiting = 0
		else:
			vy = 0
			vysubpixel = 0
			dirtywaiting = 0
	
	func try_move(dir:Vector2i) -> bool:
		var cell2 := cell + dir
		if maze.get_cell_tid(cell2) == 0:
			cell = cell2; _register(); return true
		return false
	
	var _registered_at : Variant = null
	func _register() -> void:
		if deleted: return
		_unregister()
		if maze.get_cell_tid(cell) == 0:
			_registered_at = cell
			maze.set_cell_tid(cell, tid)
	func _unregister() -> void:
		if _registered_at is Vector2i:
			maze.set_cell_tid(_registered_at, 0)
			moved_from.emit(_registered_at)
			_registered_at = null
	
	func randomizespr() -> void:
		if _registered_at is Vector2i:
			if randf() < 0.1:
				ccwrot = randi_range(0,1)-randi_range(0,1)
				maze.set_cell_tid_transformed(_registered_at, tid, ccwrot)

const BOOKS : Array[int] = [3,4,5,6,]
@onready var bigbookgen = generate_a_hundred_stupid_books()
var bookseeds := range(100)
var bookseedsindex := 0
func _ready() -> void:
	for cell in maze.get_used_cells_by_tids(BOOKS):
		maze.set_cell_tid(cell, BOOKS[randi()%4])
	bookseeds.shuffle()
	#for cell in maze.get_used_cells_by_tids([1,14]):
		#var above : int = 0
		#for i in range(1,20):
			#if maze.get_cell_tid(cell + Vector2i(0,-i)) == 0:
				#above += 1
				#continue
			#else:
				#break
		#if above > 0:
			#var climb : int = randi() % (above+1)
			#for y in range(1,climb):
				#maze.set_cell_tid(cell + Vector2i(0,-y), BOOKS[randi()%len(BOOKS)])

var book_phase_update : int

func _physics_process(_delta: float) -> void:
	if bookseedsindex < 100 and randi () % 100 >= bookseedsindex:
		spawnrandombook(bookseeds[bookseedsindex])
		bookseedsindex += 1
	book_phase_update += 1
	if book_phase_update % 3 == 1:
		var odd : int = (book_phase_update % 6 < 3) as int
		var i : int = 0
		for book in books:
			if book.dirty and i % 2 == odd: book.update()
			i += 1
	if book_phase_update == 5:
		books.shuffle()
		book_phase_update = 0

func spawnrandombook(volumeindex : int) -> void:
	var bookspawnpositions : Array[Vector2i]
	for cell in maze.get_used_cells_by_tids([1,14]):
		if cell.x <= 1 and cell.y >= 7: continue
		var freecells : int = 0
		var topcell = null
		for i in range(1,20):
			match maze.get_cell_tid(cell + Vector2i(0, -i)):
				0: freecells += 1 # empty space
				3,4,5,6: pass # book
				_: topcell = cell + Vector2i(0, -i+1)
			if topcell: break
		if topcell is Vector2i: for _i in freecells: bookspawnpositions.append(topcell as Vector2i)
	if bookspawnpositions:
		addbook(BookObj.new(maze, bookspawnpositions[randi() % len(bookspawnpositions)], volumeindex, bigbookgen[volumeindex]))
	else:
		print("error, could not spawn book :(")
var books : Array[BookObj]

func addbook(book:BookObj) -> void:
	book.moved_from.connect(_dirty_books_at_above)
	books.append(book)

func _dirty_books_at_above(dirtyingcell:Vector2i) -> void:
	for book in books:
		if abs(book.cell.x-dirtyingcell.x) <= 1 and abs(book.cell.y-dirtyingcell.y) <= 1:
			book.dirty = true

func get_book_at_cell(cell:Vector2i):
	for book in books:
		if book.cell == cell: return book

# global
var ags : Dictionary
var nextspans : Array[String]

func generate_a_hundred_stupid_books():
	var a_hundred_books = []
	seed(0)
	ags = {"AGAIN": 1, "AGAIN AND AGAIN": 1}
	nextspans = [
		#01234567890123456789
		"LOOK AND SEE AND",
		"LOOK AGAIN UNTIL YOU",
		"SEE AGAIN AND LOOK",
		"AGAIN AND AGAIN",
	]
	for volumeindex in 100:
		var lines : Array[String] = []
		lines.append("LOOK AND SEE VOL. %d" % (volumeindex+1))
		var numlines : int = randi_range(5,8)
		if volumeindex == 99: numlines = 2;
		while len(lines)<numlines:
			if len(nextspans)>1:
				lines.append(nextspans.pop_front())
			else:
				tryappendnewag()
			if len(nextspans)<=1:
				break
		if volumeindex == 99:
			nextspans[-1] += ","
			for j in len(nextspans):
				lines.append(nextspans[j])
			lines.append("UNTIL YOU SEE.")
		#for line in lines:
			#print(line)
		a_hundred_books.append(PackedStringArray(lines))
	randomize()
	return a_hundred_books

func tryappendnewag():
	#var i := 0
	var ag := make_random_ag()
	nextspans[-1] += "," # non-optional
	var new_ag_phrase = "AND " + ag
	if ags.has(ag):
		new_ag_phrase += " (AGAIN"
		for _i in ags[ag]-1: new_ag_phrase += ", AGAIN"
		new_ag_phrase += ")"
	ags[ag] = ags.get(ag,0) + 1
	var new_words = new_ag_phrase.split(" ")
	var new_word_lengths = (new_words as Array).map(len)
	var wordcount : int = len(new_words)
	var lastwordw : int = wordcount - 1
	for w in wordcount:
		if len(nextspans[-1]) + new_word_lengths[w] < 20:
			nextspans[-1] += " " + new_words[w]
		else:
			nextspans.append(new_words[w])

func make_random_ag() -> String:
	var ag = "AGAIN"
	var ands : bool = randf() < 0.7
	var linear_count = int(12 * pow(randf(),2))
	for i in linear_count:
		if ands: ag += " AND"
		ag += " AGAIN"
	return ag
