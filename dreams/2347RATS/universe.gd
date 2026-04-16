extends Node2D

@export var always_jumping_rat : bool = false
@export var jumping_chance : float = 0.00
@export var rat_revive_timer : int = -1
@export var rat_always_floored : bool = false
@export var rat_force_dpadx : int = 0
@export var dpadchange_chance : float = 0.00
@export var dpadzero_chance : float = 0.00
@export var tethered_to_original_dist : float = 50.0
@export var teleports_to_random_cell_within : int = 0
@export var teleport_chance : float = 0.0
@export var teleports_to_random_universe_chance : float = 0.0
@export var never_visible : bool = false
const SOLIDS = [1,2,3,4,19]
const NOTSOLIDS = [0,5,7,18]
	# skipping spikes, they dont count

@onready var rat = get_child(0) as NavdiSolePlayerBasics
var maze : Maze
var rat_last_floor_cell : Vector2i
var rat_dead_duration : int = 0

#func _ready() -> void:
	#$Rat/mover/solidcast.collision_mask

func game_must_revive() -> bool:
	return rat_revive_timer >= 0 and rat_dead_duration >= rat_revive_timer

func setup(_maze : Maze, universe_index : int, crate_positions : Array[Vector2], vessel : NavdiVessel):
	rat.z_index = 2 # always on top of crates
	$Crates.z_index = 1 # always on top of maze
	maze = _maze
	var universe_solid_flag = 1 << universe_index
	for crate_pos in crate_positions:
		var crate : CharacterBody2D = vessel.spawn_exile_by_name("Crate", $Crates)
		crate.position = crate_pos
		crate.collision_mask |= universe_solid_flag
		crate.collision_layer = universe_solid_flag
	$Rat/mover/solidcast.collision_mask |= universe_solid_flag
	return self

func _physics_process(_delta: float) -> void:
	if dpadchange_chance and randf() < dpadchange_chance:
		rat_force_dpadx = randi_range(-1,1)
	if dpadzero_chance and randf() < dpadzero_chance:
		rat_force_dpadx = 0
	
	if not rat.dead and not rat.exited:
		rat_dead_duration = 0
		var ratcell = maze.local_to_map(rat.position)
		if maze.get_cell_tid(ratcell) == 6:
			rat.position.y = maze.map_to_local(ratcell).y - 5
			rat.dead = true
			rat.vy = 0.0
		if maze.get_cell_tid(ratcell) == 99:
			rat.exited = true
		if rat.onfloor:
			if (maze.get_cell_tid(ratcell)
				in NOTSOLIDS
			and maze.get_cell_tid(ratcell+Vector2i(0,1))
				in SOLIDS
			):
				rat_last_floor_cell = ratcell
		if always_jumping_rat or (jumping_chance and randf() < jumping_chance):
			rat.bufs.on(rat.JUMPBUF)
			rat.force_highest_jump = true
	else:
		if rat_dead_duration < 999999:
			rat_dead_duration += 1

func copy_universe(universe) -> void:
	if universe.rat.exited:
		return # no copy.
	rat.copy_rat(universe.rat)
	for i in $Crates.get_child_count():
		$Crates.get_child(i).copy_crate(universe.get_node("Crates").get_child(i))
