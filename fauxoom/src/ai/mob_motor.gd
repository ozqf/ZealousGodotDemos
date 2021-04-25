extends Spatial
class_name MobMotor

const STATE_IDLE:int = 0
const STATE_HUNT:int = 1
const STATE_PATROL:int = 2
const STATE_LEAP:int = 3

var _floorInFront:RayCast

enum MobMoveType {
	Ground,
	Flying
}

enum MobMoveStyle {
	CloseStraight,
	CloseEvasive,
	KeepDistance
}

export(MobMoveType) var moveType = MobMoveType.Ground
export(MobMoveStyle) var moveStyle = MobMoveStyle.CloseStraight
export var inactiveWhenAttacking:bool = false

var _body:KinematicBody = null

var _velocity:Vector3 = Vector3()

var _state:int = STATE_IDLE
var _speed:float = 4.5
var _acceleration:float = 25.0
var _stunned:bool = false
var _hasTarget:bool = false
var _isAttacking:bool = false
var _target:Vector3 = Vector3()

var _thinkTime:float = 1
var _tick:float = 0.0
var _yawOffset:float = 0.0

func custom_init(body:KinematicBody) -> void:
	_body = body
	_floorInFront = $floor_in_front

func change_state(state:int) -> void:
	_state = state

func leap() -> void:
	if !_hasTarget:
		return
	change_state(STATE_LEAP)
	var selfPos:Vector3 = _body.global_transform.origin
	var moveYaw:float = ZqfUtils.yaw_between(selfPos, _target)
	_body.rotation.y = moveYaw
	var move:Vector3 = Vector3()
	move.x = -sin(moveYaw)
	move.y = 6.5
	move.z = -cos(moveYaw)
	move *= 20.0

func set_stunned(flag:bool) -> void:
	_stunned = flag

func set_is_attacking(flag:bool) -> void:
	_isAttacking = flag

func set_target(target:Vector3) -> void:
	_hasTarget = true
	_target = target
	_state = STATE_HUNT

func clear_target() -> void:
	_hasTarget = false
	change_state(STATE_IDLE)

func damage_hit(_hitInfo:HitInfo) -> void:
	var strength:float = 1.5
	if _stunned:
		strength = 3.0
	_velocity += _hitInfo.direction * strength

func _calc_move_yaw() -> float:
	var selfPos:Vector3 = _body.global_transform.origin
	var dist:float = ZqfUtils.flat_distance_between(selfPos, _target)
	var moveYaw:float = ZqfUtils.yaw_between(selfPos, _target)
	if moveStyle == MobMoveStyle.CloseEvasive:
		if _tick <= 0:
			_tick = _thinkTime
			var offset:float = deg2rad(45)
			# _yawOffset = rand_range(-offset, offset)
			var r = randf()
			if r > 0.66:
				_yawOffset = offset
			elif r > 0.33:
				_yawOffset = -offset
			else:
				r = 0
	return moveYaw + _yawOffset

func move_idle(_delta:float) -> void:
	_velocity.y -= 20 * _delta
	_velocity = _body.move_and_slide(_velocity, Vector3.UP)
	_velocity *= 0.95

func move_hunt(_delta:float) -> void:
	_velocity.y -= 20 * _delta
	if !_body.is_on_floor():
		_velocity = _body.move_and_slide(_velocity, Vector3.UP)
		return
	_tick -= _delta
	var speed:float = 4.5
	var moveYaw:float = _calc_move_yaw()
	# if !_floorInFront.is_colliding():
	# 	speed = 0
	_body.rotation.y = moveYaw
	var move:Vector3 = Vector3()
	move.x = -sin(moveYaw)
	move.z = -cos(moveYaw)
	move *= speed
	_velocity += (move * _acceleration) * _delta
	if _velocity.length() > _speed:
		_velocity = _velocity.normalized()
		_velocity *= _speed
	_velocity = _body.move_and_slide(_velocity, Vector3.UP)

func __process(_delta:float) -> void:
	_velocity.y -= 20 * _delta
	if _stunned || _isAttacking || _state == STATE_IDLE:
		move_idle(_delta)
		# # assume idle
		# _velocity = _body.move_and_slide(_velocity, Vector3.UP)
		# _velocity *= 0.95
	elif _state == STATE_HUNT:
		move_hunt(_delta)
