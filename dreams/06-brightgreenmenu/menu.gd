extends RichTextLabel


class MenuItem:
	var name : String
	var dream : NavdiDream
	func _init(d:NavdiDream) -> void:
		self.dream = d
		self.name = (d.resource_path
					.rsplit("/",false,1)[1]
					.replace("Dream.tres","")
					.rstrip("_-"))
	enum {
		PERFECT_AND_START = 3,
		PERFECT = 2,
		SOMEWHERE = 1,
		NOMATCH = 0,
	}
	func _s(scorevalue):
		last_match_score = scorevalue
		return last_match_score
	var last_match_score:int
	var last_match_bbcodename:String
	func get_match_score(searchstring:String) -> int:
		if searchstring:
			var nn = name.to_lower()
			var ss = searchstring.to_lower()
			var matchi : int = nn.find(ss)
			if matchi >= 0:
				last_match_bbcodename = ("%s[color=#fff][u]%s[/u][/color]%s" % [
					name.substr(0,matchi),
					name.substr(matchi,len(ss)),
					name.substr(matchi+len(ss)),
				])
				return _s(PERFECT_AND_START if matchi else PERFECT)
			var si = 0
			last_match_bbcodename = ''
			for ni in range(len(nn)):
				if si < len(ss) and nn[ni] == ss[si]:
					last_match_bbcodename += "[color=#fff][u]" + name[ni] + "[/u][/color]"
					si += 1;
				else:
					last_match_bbcodename += name[ni]
			if si >= len(ss):
				return _s(SOMEWHERE)
		last_match_bbcodename = ''
		return _s(NOMATCH)

const BLINK_ON : int = 45
const BLINK_OFF : int = 30 + BLINK_ON
var blinka : int = BLINK_ON
var cursor : int = -1
var menu : Array[MenuItem]
var _lastsearch : String = ''
var searchstring : String = ''
var searchcursor : int = 0
var searchresults : Array[MenuItem]

func fetch_all_dreams_to_menu():
	for dirname in DirAccess.get_directories_at("res://dreams/"):
		for filename in DirAccess.get_files_at("res://dreams".path_join(dirname)):
			if filename.ends_with("Dream.tres"):
				var dream : NavdiDream = ResourceLoader.load(
					"res://dreams"
					.path_join(dirname)
					.path_join(filename)
				)
				if dream and not dream in Dreamer.dream_stack:
					menu.append(MenuItem.new(dream))

func _ready() -> void:
	fetch_all_dreams_to_menu()
	searchstring = Dreamer.r("searchstring", "")
	if searchstring:
		searchcursor = Dreamer.r("cursor", 0)
	else:
		cursor = Dreamer.r("cursor", -1)
	update_text()
func _physics_process(_delta: float) -> void:
	if _lastsearch != searchstring:
		_lastsearch = searchstring
		update_search()
	else:
		update_text()

func update_search() -> void:
	blinka = -20
	searchresults.clear()
	searchcursor = 0
	if searchstring:
		searchresults = menu.filter(func(mi):
			return mi.get_match_score(searchstring))
		searchresults.sort_custom(func(a,b):
			return a.last_match_score>b.last_match_score)
	Dreamer.w("searchstring", searchstring)
	Dreamer.w("cursor", searchcursor if searchstring else cursor)

func update_text() -> void:
	blinka += 1; if blinka >= BLINK_OFF: blinka = 0
	text = "%s%s\n" % [searchstring, "|" if blinka < BLINK_ON else ""]
	if searchstring:
		text += submenu_string(searchresults,searchcursor,5,true)
	else:
		text += submenu_string(menu,cursor,5)

func submenu_string(items:Array[MenuItem],c:int,window:int,use_bbcodename:bool=false) -> String:
	var s:String = ''
	@warning_ignore("integer_division")
	var mi = c - window/2 # floor
	if mi + window - 1 >= len(items):
		mi = len(items) - window
	if mi < 0: mi = 0
	for i in range(mi,mi+window):
		s += "\n"
		if i < len(items):
			var itemname = items[i].last_match_bbcodename if use_bbcodename else items[i].name
			if i == c: s += "[b]%s ⬅[/b]" % itemname
			else: s += itemname
		else:
			if i == 0: s += "[color=#176][i]none[/i][/color]"
			else: s += "[color=#176][i]    -[/i][/color]"
	return s

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		var key_char: String = char(event.unicode) if event.unicode else ''
		if key_char.length() == 1 and key_char != ' ':
			if !event.shift_pressed: key_char = key_char.to_lower()
			searchstring += key_char
		else:
			var dy : int = 0
			match event.keycode:
				KEY_BACKSPACE:
					if searchstring:
						searchstring = searchstring.substr(0, len(searchstring)-1)
				KEY_UP: dy = -1
				KEY_DOWN: dy = 1
				KEY_LEFT, KEY_PAGEUP: dy = -5
				KEY_RIGHT, KEY_PAGEDOWN: dy = 5
				KEY_ENTER:
					if searchstring:
						if searchresults and searchcursor >= 0:
							Dreamer.dream(searchresults[searchcursor].dream)
					elif cursor >= 0:
						Dreamer.dream(menu[cursor].dream)
			if dy:
				if searchstring:
					searchcursor = clamp(searchcursor+dy,0,max(0,len(searchresults)-1))
					cursor = -1
				else:
					cursor = clamp(cursor+dy,0,max(0,len(menu)-1))
				Dreamer.w("cursor", searchcursor if searchstring else cursor)
				if blinka > BLINK_ON: blinka = BLINK_ON # hide
