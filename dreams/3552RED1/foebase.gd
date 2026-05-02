extends Node2D

var cell : Vector2i
var blockade_weight : float = 0.0


enum { OUCHBUF, DEADBUF, }

var bufs : Bufs
var stage
var maze : Maze
var targetplayer
var vx : float; var vy : float;
var hp : int = 100;
var awake : bool = false; # enemies start asleep.
var dead : bool = false;
@onready var mover : NavdiBodyMover = $mover
@onready var solidcast : ShapeCast2D = $mover/solidcast

func setup(_stage, _maze : Maze, _pos : Vector2):
	bufs = Bufs.Make(self).setup_bufons([
		OUCHBUF,8, DEADBUF,8,
	])
	self.stage = _stage
	self.maze = _maze
	self.position = _pos
	return self

func try_hitby(_hitter) -> bool:
	var damage = _hitter.get('damage')
	if damage is int and damage > 0: pass
	else: damage = 10 # default damage: 10
	hp -= damage # take damage? could do a calculation
	bufs.on(OUCHBUF)
	if hp <= 0 and not dead: self.die()
	self.awaken()
	return true

func die() -> void:
	if not dead:
		dead = true
		bufs.on(DEADBUF)

func awaken() -> void:
	if not awake:
		awake = true
