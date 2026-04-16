extends Node2D

@onready var vessel = $"../NavdiVessel"
@onready var player = $artplayer
@onready var maze = $Maze
var arrowdelay : int = 100
var bgm_playing : bool = true
var bgm_fading : bool = false
var _fadevolum : float = 0.5

func _physics_process(_delta: float) -> void:
	if arrowdelay > 0:
		arrowdelay -= 1
	else:
		spawn_arrow(0,45)
		spawn_arrow(55,100)
		arrowdelay = randi_range(50,500)
	
	#if bgm_fading:
		#if _fadevolum > 0:
			#_fadevolum -= 0.001
			#$bgmdull.volume = _fadevolum
		#else:
			#$bgmdull.stop()
			#bgm_fading = false
	
	if is_instance_valid(player):
		var overlappingarrows = []
		for a in $Arrows.get_children():
			if taxicab_distance(a.position,player.position)<9.1:
				overlappingarrows.append(a)
		if overlappingarrows and player.vx > 0: player.vx = 0
		for a in overlappingarrows:
			player.push_x(a.xmoved)
	
		if player.gaaaaah:
			if bgm_playing:
				$ahfuck2.play();
				$bgm.pause();
				bgm_playing = false;
			for _i in 8:
				var x = randi_range(1,8)
				var y = randi_range(1,8)
				match randi() % 20:
					0: x = [0,9][randi()%2]
					1: y = [0,9][randi()%2]
				var mcell := Vector2i(x,y)
				match maze.get_cell_tid(mcell):
					99:
						maze.set_cell_tid(mcell,3)
						maze.set_cell_tid(Vector2i(1,1),3)
						maze.set_cell_tid(Vector2i(1,8),3)
						maze.set_cell_tid(Vector2i(8,1),3)
						maze.set_cell_tid(Vector2i(8,8),3)
					0:
						if x == 8 and y == 0: pass
						else: maze.set_cell_tid(mcell,[4,5,6,7][randi()%4])
					_:
						maze.set_cell_tid(mcell,3)
		else:
			if not bgm_playing:
				$ahfuck2.stop();
				$bgm.play();
				bgm_playing = true;
				for mcell in maze.get_used_cells_by_tids([3,4,5,6,7,]):
					if mcell.x==0 or mcell.y==0 or mcell.x==9 or mcell.y==9:
						maze.set_cell_tid(mcell,[1,2,2,2,2,][randi()%5])
					else:
						maze.set_cell_tid(mcell,[0,0,0,1,2][randi()%5])
				if not maze.get_used_cells_by_tids([99]):
					var pcell = maze.local_to_map(player.position)
					var holex = 1 if pcell.x > randi_range(3,5) else 8
					var holey = 1 if pcell.y > randi_range(5,9) else 8 # exit easier
					maze.set_cell_tid(Vector2i(holex, holey), 99)
	
		var pcells = [maze.local_to_map(player.position)]
		for dx in [-2.5,0,2.5]:
			for dy in [-2.5,0,2.5]:
				if dx or dy:
					var new_pcell = maze.local_to_map(player.position + Vector2(dx,dy))
					if not (new_pcell in pcells):
						pcells.append(new_pcell)
		for pcell in pcells:
			if maze.get_cell_tid(pcell) in [1,2]:
				maze.set_cell_tid(pcell, 0) # erase.
		#print(pcells)
		if (len(pcells) == 1
		and maze.get_cell_tid(pcells[0]) == 99
		and taxicab_distance(maze.map_to_local(pcells[0]), player.position + Vector2.UP) <= 2.5
		):
			player.queue_free() # bye.
			$descend.play()
			#$bgm.stop()
			#$bgmdull.play()
			#bgm_fading = true
	
func taxicab_distance(a:Vector2,b:Vector2)->float:
	return max(abs(a.x-b.x),abs(a.y-b.y))

func spawn_arrow(miny:int=0,maxy:int=100) -> void:
	var arrow = vessel.spawn_exile_by_name("ARROW", $Arrows)
	if arrow:
		arrow.position = Vector2(105,randi_range(miny,maxy))
	
