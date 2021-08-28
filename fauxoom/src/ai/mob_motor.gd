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

var moveYaw:float = 0.0
var _state:int = STATE_IDLE
var speed:float = 4.5
var _acceleration:float = 25.0
var _stunned:bool = false
var _hasTarget:bool = false
var _isAttacking:bool = false

var _target:Vector3 = Vector3()
var _targetForward:Vector3 = Vector3()

var _thinkTime:float = 1
var _tick:float = 0.0
var _yawOffset:float = 0.0

func custom_init(body:KinematicBody) -> void:
	_body = body
	_floorInFront = $floor_in_front
	if moveType == MobMoveType.Flying:
		print("Mob motor is flying")

func motor_change_state(state:int) -> void:
	_state = state

func leap() -> void:
	if !_hasTarget:
		return
	motor_change_state(STATE_LEAP)
	var selfPos:Vector3 = _body.global_transform.origin
	_set_move_yaw(ZqfUtils.yaw_between(selfPos, _target))
	# _body.rotation.y = moveYaw
	var move:Vector3 = Vector3()
	move.x = -sin(moveYaw)
	move.y = 6.5
	move.z = -cos(moveYaw)
	move *= 20.0

func set_stunned(flag:bool) -> void:
	_stunned = flag

func mob_died() -> void:
	set_stunned(true)
	moveType = MobMoveType.Ground

func set_is_attacking(flag:bool) -> void:
	_isAttacking = flag

func set_move_target(target:Vector3) -> void:
	_hasTarget = true
	_target = target
	_state = STATE_HUNT

func set_move_target_forward(targetForward:Vector3) -> void:
	_targetForward = targetForward

func _set_move_yaw(radians:float) -> void:
	moveYaw = radians
	rotation.y = moveYaw

func clear_target() -> void:
	_hasTarget = false
	motor_change_state(STATE_IDLE)

func damage_hit(_hitInfo:HitInfo) -> void:
	var strength:float = 1
	if _stunned:
		strength = 1.5
	_velocity += _hitInfo.direction * strength

func _calc_move_yaw() -> float:
	var selfPos:Vector3 = _body.global_transform.origin
	var _dist:float = ZqfUtils.flat_distance_between(selfPos, _target)
	var directYaw:float = ZqfUtils.yaw_between(selfPos, _target)
	if moveStyle == MobMoveStyle.CloseEvasive:
		if _tick <= 0:
			_tick = _thinkTime
			var selfForward:Vector3 = -_body.global_transform.basis.z

			var tarAimIsToLeft:bool = ZqfUtils.is_point_left_of_line3D_flat(_target, _targetForward, selfPos)
			print("Tar aim is to left: " + str(tarAimIsToLeft))
			var offset:float = deg2rad(65)
			if tarAimIsToLeft:
				_yawOffset = -offset
			elif !tarAimIsToLeft:
				_yawOffset = offset


			# var tarIsToLeft:bool = ZqfUtils.is_point_left_of_line3D_flat(selfPos, selfForward, _target)
			# var offset:float = deg2rad(65)
			# if tarIsToLeft:
			# 	_yawOffset = -offset
			# elif !tarIsToLeft:
			# 	_yawOffset = offset
			
			# _yawOffset = rand_range(-offset, offset)
			# var r = randf()
			# if r > 0.66:
			# 	_yawOffset = offset
			# elif r > 0.33:
			# 	_yawOffset = -offset
			else:
				_yawOffset = 0
	return directYaw + _yawOffset

func move_idle(_delta:float, friction:float = 0.95) -> void:
	if moveType == MobMoveType.Ground:
		_velocity.y -= 20 * _delta
	_velocity = _body.move_and_slide(_velocity, Vector3.UP)
	_velocity.x *= friction
	_velocity.z *= friction

func move_leap(_delta:float, _speed:float) -> void:
	var dir = _velocity.normalized()
	_velocity = dir * _speed
	_velocity = _body.move_and_slide(_velocity, Vector3.UP)

func start_leap(_delta:float, _speed:float) -> void:
	var selfPos:Vector3 = _body.global_transform.origin
	moveYaw = ZqfUtils.yaw_between(selfPos, _target)
	# _body.rotation.y = moveYaw
	var dir:Vector3 = Vector3()
	dir.x = -sin(moveYaw)
	dir.z = -cos(moveYaw)
	dir *= _speed

	_velocity = dir
	_velocity = _body.move_and_slide(_velocity, Vector3.UP)

func _hunt_ground(_delta:float) -> void:
	if moveType == MobMoveType.Ground:
		_velocity.y -= 20 * _delta
		if !_body.is_on_floor():
			_velocity = _body.move_and_slide(_velocity, Vector3.UP)
			return
	_tick -= _delta
	# var speed:float = 4.5
	_set_move_yaw(_calc_move_yaw())
	if _floorInFront != null && !_floorInFront.is_colliding():
		# print("No floor!")
		move_idle(_delta, 0.5)
		return
	# _body.rotation.y = moveYaw
	var move:Vector3 = Vector3()
	move.x = -sin(moveYaw)
	move.z = -cos(moveYaw)
	move *= speed
	_velocity += (move * _acceleration) * _delta
	if _velocity.length() > speed:
		_velocity = _velocity.normalized()
		_velocity *= speed
	_velocity = _body.move_and_slide(_velocity, Vector3.UP)

func _hunt_flying(_delta:float) -> void:
	# print("Hunt flying")
	_tick -= _delta
	_set_move_yaw(_calc_move_yaw())
	var move:Vector3 = Vector3()
	move.x = -sin(moveYaw)
	move.z = -cos(moveYaw)
	# calc y component
	# aim to float a little above target
	var diffY:float = _target.y - (_body.global_transform.origin.y - 1)
	if diffY > 0.2:
		move.y = 0.5
	elif diffY < 0.2:
		move.y = -0.5
	move *= speed
	_velocity += (move * _acceleration) * _delta
	if _velocity.length() > speed:
		_velocity = _velocity.normalized()
		_velocity *= speed
	_velocity = _body.move_and_slide(_velocity, Vector3.UP)

func move_hunt(_delta:float) -> void:
	if moveType == MobMoveType.Flying:
		_hunt_flying(_delta)
	else:
		_hunt_ground(_delta)

# func __process_not_run(_delta:float) -> void:
# 	_velocity.y -= 20 * _delta
# 	if _stunned || _isAttacking || _state == STATE_IDLE:
# 		move_idle(_delta)
# 		# # assume idle
# 		# _velocity = _body.move_and_slide(_velocity, Vector3.UP)
# 		# _velocity *= 0.95
# 	elif _state == STATE_HUNT:
# 		move_hunt(_delta)
