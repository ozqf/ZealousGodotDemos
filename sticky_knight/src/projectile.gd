extends Area2D
class_name Projectile

var _tick:float = 10.0
var _active:bool = true
var _speed:float = 300
var _radians:float = 0
var _ignoreBody:PhysicsBody2D = null

func _ready():
	var _foo = connect("body_entered", self, "on_body_enter")

func _kill():
	_active = false
	queue_free()

func hit_projectile(radians:float):
	_radians = radians
	_ignoreBody = null

func on_body_enter(_body):
	if _body == _ignoreBody:
		return
	var layer:int = _body.collision_layer
	print("prj hit layer: " + str(layer) + " vs world " + str(game.LAYER_WORLD))
	if (layer & game.LAYER_WORLD) > 0:
		_kill()
		return
	if layer & game.LAYER_WORLD_SLIPPY > 0:
		_kill()
		return

func _process(_delta:float):
	if !_active:
		return
	if _tick <= 0:
		_active = false
		queue_free()
		return
	_tick -= _delta
	var step = Vector2()
	step.x = (cos(_radians) * _speed) * _delta
	step.y = (sin(_radians) * _speed) * _delta
	position += step

func launch(ignoreBody:PhysicsBody2D, pos:Vector2, radians:float, speed:float):
	_ignoreBody = ignoreBody
	position = pos
	_radians = radians
	_speed = speed
	pass
