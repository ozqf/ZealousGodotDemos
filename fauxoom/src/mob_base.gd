extends KinematicBody
class_name MobBase

signal on_mob_died(mob)

onready var _sprite:EntitySprite = $body
onready var _attack = $attack

const MOVE_SPEED:float = 3.0
const MOVE_TIME:float = 1.5

enum MobState {
	Idle,
	Spawning,
	Hunting,
	Attacking,
	Stunned,
	Dying,
	Dead
}

var _state = MobState.Hunting
var _prevState = MobState.Hunting

var _tarId:int = 0
var _targetInfo: Dictionary = { id = 0 }

var _moveTick:float = 0
var _moveYaw:float = 0

var _thinkTick:float = 0

var _stunAccumulator:int = 0
var _stunDamageMax:int = 20

var _health:int = 100
var _dead:bool = false

var _velocity:Vector3 = Vector3()

func _ready() -> void:
	_attack.custom_init($head, self)
	add_to_group(Groups.GAME_GROUP_NAME)

func game_on_reset() -> void:
	queue_free()

func is_dead() -> bool:
	return (_state == MobState.Dead || _state == MobState.Dying)

func _calc_self_move(_delta:float) -> Vector3:
	# look_at(_curTarget.global_transform.origin, Vector3.UP)
	if _moveTick <= 0:
		# decide on next move
		_moveTick = 1
		var selfPos:Vector3 = global_transform.origin
		# var tarTrans:Transform = _curTarget.global_transform
		# var tarPos:Vector3 = tarTrans.origin
		var tarPos:Vector3 = _targetInfo.position
		var _tarYaw:float = _targetInfo.yawDegrees
		var dist:float = ZqfUtils.flat_distance_between(selfPos, tarPos)
		if dist > 15:
			_moveYaw = ZqfUtils.yaw_between(selfPos, tarPos)
		elif dist > 3:
			# var tarFacing:float = _calc_target_side(selfPos, tarPos, -tarTrans.basis.z)
			_moveYaw = ZqfUtils.yaw_between(selfPos, tarPos)
			
			# apply evasion from player aim direction
			# var leftOfTar:bool = ZqfUtils.is_point_left_of_line3D_flat(tarPos, _targetInfo.forward, selfPos)
			# if leftOfTar:
			# 	print("left at " + str(selfPos))
			# 	_moveYaw -= deg2rad(90)
			# else:
			# 	print("right at " + str(selfPos))
			# 	_moveYaw += deg2rad(90)
			
			# apply some random evasion - very jittery
			var quarter:float = deg2rad(90)
			_moveYaw -= quarter
			_moveYaw += rand_range(0, quarter * 2.0)
		else:
			_moveYaw = rand_range(0, PI * 2)
	else:
		_moveTick -= _delta
	
	rotation.y = _moveYaw
	var move:Vector3 = Vector3()
	move.x = -sin(_moveYaw)
	move.z = -cos(_moveYaw)
	move *= MOVE_SPEED
	return move
	# return Vector3()

func move(_delta:float) -> void:
	var move:Vector3 = _calc_self_move(_delta)
	var _result = self.move_and_slide(move)

func _tick_stunned(_delta:float) -> void:
	if _thinkTick <= 0:
		_state = _prevState
		return
	else:
		_thinkTick -= _delta
	_velocity = self.move_and_slide(_velocity)
	_velocity *= 0.95

func _process(_delta:float) -> void:
	if _state == MobState.Hunting:
		# var wasEmpty:bool = (_targetInfo.id == 0)
		_targetInfo = Game.mob_check_target(_targetInfo)
		# if _targetInfo.id != 0 && wasEmpty:
		# 	print("Mob got target!")
		# elif _targetInfo.id == 0 && !wasEmpty:
		# 	print("Mob lost target!")
		if _targetInfo.id == 0:
			return
		
		if _thinkTick <= 0:
			_thinkTick = MOVE_TIME
			if _attack.start_attack(_targetInfo.position):
				_state = MobState.Attacking
		else:
			_thinkTick -= _delta
			move(_delta)
	elif _state == MobState.Attacking:
		_targetInfo = Game.mob_check_target(_targetInfo)
		if _targetInfo.id == 0:
			# abort attack!
			return
		if !_attack.custom_update(_delta, _targetInfo.position):
			_state = MobState.Hunting
	elif _state == MobState.Idle:
		return
	elif _state == MobState.Spawning:
		return
	elif _state == MobState.Stunned:
		_tick_stunned(_delta)
		return
	elif _state == MobState.Dying:
		return
	elif _state == MobState.Dead:
		return

func apply_stun(dir:Vector3) -> void:
	# stun
	if _state != MobState.Stunned:
		_prevState = _state
		_state = MobState.Stunned
	_attack.cancel()
	_velocity = dir * 2
	_thinkTick = 0.2

func hit(_hitInfo:HitInfo) -> void:
	if is_dead():
		return
	_health -= _hitInfo.damage
	if _health <= 0:
		# die
		_state = MobState.Dying
		emit_signal("on_mob_died", self)
		queue_free()
	else:
		apply_stun(_hitInfo.direction)
