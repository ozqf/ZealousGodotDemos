extends Spatial
class_name Projectile

var _hitInfo_type = preload("res://src/defs/hit_info.gd")

const MAX_SPEED:float = 15.0

enum ProjectileState {
	Idle,
	InFlight,
	Dying
}

var _state = ProjectileState.Idle
var _ttl:float = 10
var _time:float = 10

var _velocity:Vector3 = Vector3()
var _mask:int = -1
var _ignoreBody = []
var _hitInfo:HitInfo = _hitInfo_type.new()

func _move_as_ray_2(_delta:float) -> void:
	var t:Transform = global_transform
	t.origin += (_velocity * _delta)
	global_transform = t

func remove_self() -> void:
	_state = ProjectileState.Idle
	queue_free()

func _move_as_ray(_delta:float) -> void:

	var t:Transform = global_transform
	var origin:Vector3 = t.origin
	look_at(origin + _velocity, t.basis.y)

	var speed:float = _velocity.length()
	if speed == 0:
		return
	var hit = ZqfUtils.quick_hitscan3D(self, speed * _delta, _ignoreBody, _mask)
	if hit:
		# do damage
		_hitInfo.damage = 15
		_hitInfo.attackTeam = 1
		_hitInfo.direction = _velocity.normalized()
		var _inflicted:int = Interactions.hitscan_hit(_hitInfo, hit)
		remove_self()
		return
	t.origin = origin + (_velocity * _delta)
	global_transform = t

func _process(_delta:float) -> void:
	if _state == ProjectileState.InFlight:
		_time -= _delta
		if _time <= 0:
			remove_self()
			return
		_move_as_ray(_delta)

func launch(origin:Vector3, _forward:Vector3, _ignoreBody:PhysicsBody, collisionMask:int) -> void:
	_time = _ttl
	_mask = collisionMask
	var t:Transform = global_transform
	t.origin = origin
	global_transform = t
	_velocity = _forward * MAX_SPEED
	look_at(origin + _velocity, t.basis.y)
	# ignore body doesn't work - parent can die and then we get
	# and 'access deleted object' error when performing a hitscan!
	# _ignoreBody = [ ignoreBody ]
	_state = ProjectileState.InFlight
