extends Area2D
class_name Projectile

onready var _sprite:Sprite = $Sprite
var _tick:float = 10.0
var _active:bool = true
var _speed:float = 300
var _radians:float = 0
var _ignoreBody:PhysicsBody2D = null
var _teamID:int = 0

func _ready():
	var _foo = connect("body_entered", self, "on_body_enter")
	var _bar = connect("area_entered", self, "on_area_enter")

func _kill():
	_active = false
	queue_free()

func hit_projectile(radians:float):
	_radians = radians
	_ignoreBody = null
	_teamID = game.TEAM_PLAYER
	_speed = 500
	refresh_colour()

func on_body_enter(_body):
	if _body == _ignoreBody:
		return
	var layer:int = _body.collision_layer
	if _teamID == game.TEAM_PLAYER && _body.has_method("hit"):
		_body.hit()
		_kill()
		return

func on_area_enter(_area):
	if _teamID == game.TEAM_PLAYER && _area.has_method("hit"):
		_area.hit()
		_kill()
		return

func refresh_colour():
	if _teamID == game.TEAM_PLAYER:
		_sprite.self_modulate = Color(1, 1, 0, 1)
	else:
		_sprite.self_modulate = Color(1, 0, 1, 1)

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
	var origin = position
	var dest = origin + step
	var mask = game.LAYER_WORLD | game.LAYER_WORLD_SLIPPY
	var spaceRId = get_world_2d().space
	var spaceState = Physics2DServer.space_get_direct_state(spaceRId)
	var result = spaceState.intersect_ray(origin, dest, [_ignoreBody], mask, true, false)
	if result:
		_kill()
		return
	position += step

func launch(ignoreBody:PhysicsBody2D, pos:Vector2, radians:float, speed:float, teamID:int):
	_ignoreBody = ignoreBody
	position = pos
	_radians = radians
	_speed = speed
	_teamID = teamID
	refresh_colour()
	pass
