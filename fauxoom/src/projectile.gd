extends Spatial
class_name Projectile

export var maxSpeed:float = 15.0
export var timeToLive:float = 10

# all projectiles have an animator
onready var animator:CustomAnimator3D = $CustomAnimator3D

# these are optional - setup in _ready
export var deathSpawnPrefab:Resource = null
var _particles = null

enum ProjectileState {
	Idle,
	InFlight,
	Dying
}

var _area:Area = null

var _state = ProjectileState.Idle
var _time:float = 10

var _velocity:Vector3 = Vector3()
var _mask:int = -1
var _team:int = Interactions.TEAM_NONE
# var _sourceId:int = 0
var _ignoreBody = []
var _hitInfo:HitInfo = null

var _explosiveRadius:float = 3

func _ready() -> void:
	_hitInfo = Game.new_hit_info()
	if has_node("Area"):
		_area = $Area
		var _r = _area.connect("scan_result", self, "area_scan_result")
	if has_node("particles"):
		_particles = $particles

func area_scan_result(bodies) -> void:
	# print("Projectile read " + str(bodies.size()) + " bodies hit")
	_hitInfo.attackTeam = _team
	_hitInfo.damageType = Interactions.DAMAGE_TYPE_EXPLOSIVE
	_hitInfo.origin = global_transform.origin
	for body in bodies:
		var tarPos:Vector3 = body.global_transform.origin
		var dist:float = _hitInfo.origin.distance_to(tarPos)
		var percent:float = 1.0 - float(dist / _explosiveRadius)
		if percent > 1:
			percent = 1
		if percent < 0:
			percent = 0
		_hitInfo.damage = int(100 * percent)
		_hitInfo.direction = tarPos - _hitInfo.origin
		_hitInfo.direction = _hitInfo.direction.normalized()
		var _inflicted:int = Interactions.hit(_hitInfo, body)

func _move_as_ray_2(_delta:float) -> void:
	var t:Transform = global_transform
	t.origin += (_velocity * _delta)
	global_transform = t

func remove_self() -> void:
	_state = ProjectileState.Idle
	queue_free()

func die() -> void:
	_state = ProjectileState.Dying
	_time = 1
	animator.hide()
	if _particles != null:
		_particles.emitting = false

	if _area != null:
		_area.run()
	if deathSpawnPrefab != null:
		var velNormal:Vector3 = _velocity.normalized()
		var instance = deathSpawnPrefab.instance()
		var t:Transform = global_transform
		t.origin -= velNormal * 0.3
		instance.global_transform = t
		get_parent().add_child(instance)

func _move_as_ray(_delta:float) -> void:

	var t:Transform = global_transform
	var origin:Vector3 = t.origin
	look_at(origin + _velocity, t.basis.y)
	# step backward slightly, or ray can sometimes penetrate walls...
	var forward = -global_transform.basis.z
	origin -= (forward * 0.1)

	var speed:float = _velocity.length()
	if speed == 0:
		return
	var hit = ZqfUtils.quick_hitscan3D(self, speed * _delta, _ignoreBody, _mask)
	if hit:
		# do damage
		_hitInfo.damage = 15
		_hitInfo.attackTeam = _team
		_hitInfo.direction = _velocity.normalized()
		var _inflicted:int = Interactions.hitscan_hit(_hitInfo, hit)
		# if _inflicted == Interactions.HIT_RESPONSE_PENETRATE:
			# print("Penetration hit!")
		# else:
			# print("Inflicted - " + str(_inflicted))
		global_transform.origin = hit.position
		die()
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
	elif _state == ProjectileState.Dying:
		_time -= _delta
		if _time <= 0:
			remove_self()

func launch_prj(origin:Vector3, _forward:Vector3, sourceId:int, prjTeam:int, collisionMask:int) -> void:
	_time = timeToLive
	_mask = collisionMask
	_team = prjTeam
	_hitInfo.sourceId = sourceId
	_hitInfo.damageType = 0
	var t:Transform = global_transform
	t.origin = origin
	global_transform = t
	_velocity = _forward * maxSpeed
	look_at(origin + _velocity, t.basis.y)
	# ignore body doesn't work - parent can die and then we get
	# and 'access deleted object' error when performing a hitscan!
	# _ignoreBody = [ ignoreBody ]
	_state = ProjectileState.InFlight
