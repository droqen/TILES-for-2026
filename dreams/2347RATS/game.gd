extends Node2D

@onready var universes := $Universes.get_children()
@onready var universect := len(universes)
@onready var maze : Maze = $Maze
@onready var vessel : NavdiVessel = $V

const VIABLEPOSITIONS = [0,5,6,7,18]

func _ready() -> void:
	var crate_positions : Array[Vector2]
	for cratecell in maze.get_used_cells_by_tids([1]):
		maze.set_cell_tid(cratecell, 0)
		crate_positions.append(maze.map_to_local(cratecell))
	for i in len(universes):
		universes[i].setup(maze, i+1, crate_positions, vessel)
		universes[i].hide()
	universes[0].show()
func _physics_process(_delta: float) -> void:
	var visiblecount : int = 0
	for universe in universes:
		if universe.tethered_to_original_dist > 0:
			if universe.rat.position.distance_squared_to(universes[0].rat.position) > universe.tethered_to_original_dist * universe.tethered_to_original_dist:
				universe.copy_universe(universes[0])
		if universe.never_visible:
			universe.hide()
		elif randf() < 0.01:
			universe.visible = not universe.visible
			if universe.visible: universe.rat.bufs.on(universe.rat.APPEARBUF)
		if universe.visible: visiblecount += 1
		if universe.game_must_revive() or (universe.teleports_to_random_universe_chance and randf()<universe.teleports_to_random_universe_chance):
			universe.copy_universe(pick_random_universe())
		if universe.rat_always_floored:
			if not universe.rat.onfloor:
				if universe.rat_last_floor_cell.y > 0:
					universe.rat.position = maze.map_to_local(universe.rat_last_floor_cell)
					universe.rat.vx = 0.0
					universe.rat.vy = 0.0
					universe.rat.mover.try_move(universe.rat, universe.rat.solidcast, VERTICAL, 5) # floor me.
					universe.rat.dead = false
		if universe.teleport_chance and randf() < universe.teleport_chance:
			var ratcell = maze.local_to_map(universe.rat.position)
			for _i in range(10):
				var targetcell = ratcell + Vector2i(
					randi_range(-universe.teleports_to_random_cell_within,universe.teleports_to_random_cell_within),
					randi_range(-universe.teleports_to_random_cell_within,universe.teleports_to_random_cell_within))
				if maze.get_cell_tid(targetcell) in VIABLEPOSITIONS:
					universe.rat.position = maze.map_to_local(targetcell)
					universe.rat.mover.try_move(universe.rat, universe.rat.solidcast, VERTICAL, 100)
					break
		universe.rat.force_dpadx = universe.rat_force_dpadx
	
	if not visiblecount: universes[0].show(); universes[0].rat.bufs.on(universes[0].rat.APPEARBUF)
func pick_random_universe():
	return universes[randi()%universect]
