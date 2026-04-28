extends Node2D

@export var player : Node2D
@onready var maze : Maze = $Maze
@onready var vessel : NavdiVessel = $"../V"

var fizzing : bool = false

@onready var label_default_yellow : Color = $ColorRect/Label.modulate

var labelflash : int = 0
func flash() -> void: labelflash = 5; #$ColorRect/Label.modulate = Color.WHITE

func _ready() -> void:
	$Foes.fizzingchanged.connect(func(prev,curre):
		if curre > prev:
			for i in range(prev,curre):
				var damage_beep : NavdiBeep = [$damage1,$damage2,$damage3][i%3]
				if i < 3:
					damage_beep.play()
					#print("play ",i)
				else:
					damage_beep.stop(); damage_beep.play.call_deferred()
					#print("re-play ",i)
		if curre < prev:
			for i in range(curre,prev):
				if i<3:
					[$damage1,$damage2,$damage3][i].stop()
					#print("stop ",i)
	)
	
	await player.firstmoved
	if not is_inside_tree(): return
	#await get_tree().create_timer(randf_range(0.5,1.0)).timeout
	#if not is_inside_tree(): return
	spawnfoe.call_deferred("golpit")
	
var phase := 0
var tempo := 150
var fadingvol01 : float = 0.0

var all_bgms_stopped : bool = true;
func stop_all_bgms() -> void:
	if not all_bgms_stopped:
		$bgm01.stop(); $bgm23.stop(); $bgm45.stop();
		all_bgms_stopped = true
func try_resume_all_bgms() -> void:
	if all_bgms_stopped:
		$bgm01.play(); $bgm23.play(); $bgm45.play();
		all_bgms_stopped = false

func _physics_process(_delta: float) -> void:
	if labelflash > 0:
		labelflash -= 1
		if labelflash <= 0:
			$ColorRect/Label.modulate = label_default_yellow
	
	phase += 1
	var living_child_count : int = $Foes.get_living_child_count()
	var vol01 := 0.0
	var vol23 := 0.0
	var vol45 := 0.0
	if living_child_count >= 1: vol01 += 0.55
	if living_child_count >= 2: vol23 += 0.55
	if living_child_count >= 3: vol45 += 0.20
	if living_child_count >= 4: vol45 += 0.15
	if living_child_count >= 5: vol45 += 0.10
	if living_child_count >= 6: vol45 += 0.05
	if living_child_count >= 7: vol45 += 0.05

	if vol01 <= 0.0001:
		if $Foes.childcount == 0:
			if fadingvol01 > 0.001:
				fadingvol01 *= 0.996 # graaadual fade.
				vol01 = fadingvol01
			else: vol01 = 0.0
		else:
			if fadingvol01 > 0.0:
				fadingvol01 -= 0.005
				vol01 = fadingvol01
	else:
		fadingvol01 = 0.55
	
	#if $Foes.fizzingchildren > 0:
		## damp all music if thers a fizzer in the mixxxx
		#vol01 *= 0.5
		#vol23 *= 0.5
		#vol45 *= 0.5
	#print("volumes %f %f %f" % [vol01,vol23,vol45])
	
	if vol01 <= 0.0: stop_all_bgms()
	else: try_resume_all_bgms()
	$bgm01.volume = vol01
	$bgm23.volume = vol23
	$bgm45.volume = vol45
	tempo = 190 + 15 * living_child_count
	if living_child_count <= 1: tempo -= 15
	if living_child_count <= 0: tempo = 1 + int(174 * fadingvol01/0.55)
	$bgm01.tempo = tempo
	$bgm23.tempo = tempo
	$bgm45.tempo = tempo
	
	if not is_instance_valid(player):
		$Foes.playergone = true
	elif (is_instance_valid(player)
	and player.position.x > 135
	and maze.get_cell_tid(maze.local_to_map(player.position))==99
	):
		player.queue_free()
		$goodbye0.play()
		flash()

func shoot(
	shooter:Node2D,
	dir:Vector2i,
	posoffset:Vector2=Vector2.ZERO,
	)->void:
		(vessel
		.spawn_exile_by_name("PlayerPew", $PlayerPews)
		.setup(shooter.position + posoffset, dir)
		)
		$pew1.play()

func spawnfoe(foename,sourcefoe=null)->void:
	get_node("spwn%d" % [randi()%4]).play()
	var foe = (vessel
		.spawn_exile_by_name(foename, $Foes)
		.setup(
				Vector2(135+randf(),75+randf()),
				self,
				self.player,
		)
	)
	if sourcefoe: foe.setup_copyfrom(sourcefoe)
	foe.onimhit.connect(func(hpleft): get_node("ouch%d"%(4-hpleft)).play() )
	foe.onwannadupe.connect(func(): spawnfoe(foename,foe); flash() )
	foe.onwannadie.connect(func(): $Foes.queue_free_if_not_last(foe)) # bye
	foe.exited99.connect(func(): [$goodbye1, $goodbye2][goodbyeindex].play(); goodbyeindex = (goodbyeindex+1) % 2; flash() )

var goodbyeindex := 0
