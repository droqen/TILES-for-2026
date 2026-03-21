extends Node2D
@onready var player : Node2D = $digger
@onready var view = $View
@onready var maze : Maze = $Maze

var target_y := 0
var camera_paws := 0
@onready var bottom_y = $GUIDANCE2.position.y-181

func _physics_process(_delta: float) -> void:
	
	if pakubuf > 0: pakubuf -= 1
	
	if !is_instance_valid(player):
		return
	
	if player.onfloor and player.jumps:
		target_y = floori(clamp(player.position.y - 100,0,bottom_y)/5.0)*5
	if !player.is_frozen:
		if camera_paws > 0:
			camera_paws -= 1
		else:
			view.move_to(Vector2(
				view.position.x,
				move_toward(view.position.y, target_y, 1)
			))
			camera_paws = 1
	
	var pcell := maze.local_to_map(player.position)
	match maze.get_cell_tid(pcell):
		0:
			maze.set_cell_tid(pcell, 40)
			player.freeze()
			playpaku()
		30:
			maze.set_cell_tid_transformed(pcell, 31, 0,
				maze.is_cell_flipped_h(pcell),
				maze.is_cell_flipped_v(pcell),
				maze.is_cell_transposed(pcell)
			)
			player.freeze()
			playpaku()
		99:
			player.queue_free()
			playpaku()
			await get_tree().create_timer(0.4).timeout
			if is_instance_valid(maze):
				maze.set_cell_tid(pcell, 40)

@onready var pakus = [
	$paku1,
	$paku2,
	$paku3,
	$paku4,
	$paku5,
]

var lastplayedpaku := -1
var pakubuf := 0

func playpaku() -> void:
	if pakubuf <= 0: lastplayedpaku = -1
	match lastplayedpaku:
		-1: pakus[0].play(); lastplayedpaku = 0;
		0: pakus[1].play(); lastplayedpaku = 1;
		1: pakus[2].play(); lastplayedpaku = 2;
		2: pakus[3].play(); lastplayedpaku = 3;
		3: pakus[4].play();
	pakubuf = 20
