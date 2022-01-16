extends Spatial
class_name Projectile

export var maxSpeed:float = 15.0
export var timeToLive:float = 10
export var spawnTime:float = 0

# all projectiles have an animator
onready var animator:CustomAnimator3D = $CustomAnimator3D

# these are optional - setup in _ready
export var deathSpawnPrefab:Resource = null

enum ProjectileState {
	Idle,
	InFlight,
	Dying,
	Spawning
}

var _state = ProjectileState.Idle
var _time:float = 10

var _velocity:Vector3 = Vector3()
var _mask:int = -1
var _team:int = Interactions.TEAM_NONE
var _ignoreBody = []
var _hitInfo:HitInfo = null

var _explosiveRadius:float = 3
var ownerId:int = 0

func _ready() -> void:
	_hitInfo = Game.new_hit_info()
	visible = false

func triggered_detonate() -> void:
	if _state != ProjectileState.InFlight:
		return
	_hitInfo.attackTeam = _team
	_hitInfo.direction = _velocity.normalized()
	die()

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
	ZqfUtils.look_at_safe(self, origin + _velocity)
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
	elif _state == ProjectileState.Spawning:
		_time -= _delta
		if _time <= 0:
			_time = timeToLive
			visible = true
			_state = ProjectileState.InFlight

func launch_prj(origin:Vector3, _forward:Vector3, sourceId:int, prjTeam:int, collisionMask:int) -> void:
	_mask = collisionMask
	_team = prjTeam
	_hitInfo.sourceId = sourceId
	_hitInfo.damageType = 0
	var t:Transform = global_transform
	t.origin = origin
	global_transform = t
	_velocity = _forward * maxSpeed
	ZqfUtils.look_at_safe(self, origin + _velocity)
	
	# start flying immediately
	if spawnTime <= 0:
		_time = timeToLive
		_state = ProjectileState.InFlight
		visible = true
	else:
		# run spawning timer
		_time = spawnTime
		_state = ProjectileState.Spawning
