extends Node
class_name MobMotor

const STATE_IDLE:int = 0
const STATE_HUNT:int = 1
const STATE_PATROL:int = 2

var _body:KinematicBody = null

var _velocity:Vector3 = Vector3()

var _state:int = STATE_IDLE
var _speed:float = 4.5
var _acceleration:float = 25.0
var _stunned:bool = false
var _hasTarget:bool = false
var _target:Vector3 = Vector3()

func custom_init(body:KinematicBody) -> void:
	_body = body

func change_state(state:int) -> void:
	_state = state

func set_stunned(flag:bool) -> void:
	_stunned = flag

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

func _process(_delta:float) -> void:
	if _stunned || _state == STATE_IDLE:
		# assume idle
		_velocity = _body.move_and_slide(_velocity)
		_velocity *= 0.95
	elif _state == STATE_HUNT:
		var moveYaw:float = ZqfUtils.yaw_between(_body.global_transform.origin, _target)
		_body.rotation.y = moveYaw
		var move:Vector3 = Vector3()
		move.x = -sin(moveYaw)
		move.z = -cos(moveYaw)
		move *= 4.5
		_velocity += (move * _acceleration) * _delta
		if _velocity.length() > _speed:
			_velocity = _velocity.normalized()
			_velocity *= _speed
		_velocity = _body.move_and_slide(_velocity)
