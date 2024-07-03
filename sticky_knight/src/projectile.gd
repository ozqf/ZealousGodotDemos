extends Area2D
class_name Projectile

@onready var _sprite:Sprite2D = $Sprite2D
var _tick:float = 10.0
var _active:bool = true
var _speed:float = 300
var _radians:float = 0
var _ignoreBody:CollisionObject2D = null
var _teamID:int = 0

func _ready():
	var _foo = connect("body_entered", Callable(self, "on_body_enter"))
	var _bar = connect("area_entered", Callable(self, "on_area_enter"))

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
	#var layer:int = _body.collision_layer
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
	if _teamID != game.TEAM_PLAYER:
		mask |= game.LAYER_PLAYER
	var spaceRId = get_world_2d().space
	var spaceState = PhysicsServer2D.space_get_direct_state(spaceRId)
	var rayParams:PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.new()
	rayParams.from = origin
	rayParams.to = dest
	
	if _ignoreBody != null && _ignoreBody.has_method("get_rid"):
		rayParams.exclude = [_ignoreBody.get_rid()]
	rayParams.collision_mask = mask
	#rayParams.area
	#var result = spaceState.intersect_ray(origin, dest, [_ignoreBody], mask, true, false)
	var result = spaceState.intersect_ray(rayParams)
	if result:
		var tileMap:TileMap = result.collider as TileMap
		if tileMap != null:
			_kill()
			return
		var layer:int = result.collider.collision_layer
		if (layer & game.LAYER_PLAYER) != 0:
			#print("Hit player!")
			result.collider.touch_projectile(self)
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
