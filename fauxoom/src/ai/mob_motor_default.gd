# Old motor, no pathfinding. Do not use!
# Kept for debugging purposes.
extends MobMotor

var _acceleration:float = 25.0

var _thinkTime:float = 0.25
var _tick:float = 0.0
var _yawOffset:float = 0.0

func leap() -> bool:
	if !_hasTarget:
		return false
	motor_change_state(STATE_LEAP)
	var selfPos:Vector3 = _body.global_transform.origin
	_set_move_yaw(ZqfUtils.yaw_between(selfPos, moveTargetPos))
	# _body.rotation.y = moveYaw
	var move:Vector3 = Vector3()
	move.x = -sin(moveYaw)
	move.y = 6.5
	move.z = -cos(moveYaw)
	move *= 20.0
	return true

func _calc_move_yaw() -> float:
	var selfPos:Vector3 = _body.global_transform.origin
	var distSqr:float = ZqfUtils.flat_distance_sqr(selfPos, moveTargetPos)
	var directYaw:float = ZqfUtils.yaw_between(selfPos, moveTargetPos)
	if moveStyle == MobMoveStyle.CloseEvasive:
		if _tick <= 0:
			_tick = _thinkTime
			var selfForward:Vector3 = -_body.global_transform.basis.z

			var tarAimIsToLeft:bool = ZqfUtils.is_point_left_of_line3D_flat(moveTargetPos, _targetForward, selfPos)
			# print("Tar aim is to left: " + str(tarAimIsToLeft))
			var offset:float = 0
			if _mob.get_health_percentage() < 50 && distSqr < (30 * 30):
				# panic move
				offset = deg_to_rad(randf_range(panicEvadeDegreesMin, panicEvadeDegreesMax))
			else:
				# normal move
				offset = deg_to_rad(evadeDegrees)
			if tarAimIsToLeft:
				_yawOffset = -offset
			elif !tarAimIsToLeft:
				_yawOffset = offset
			else:
				_yawOffset = 0
	return directYaw + _yawOffset

func move_idle(_delta:float, friction:float = 0.95) -> bool:
	if moveType == MobMoveType.Ground:
		_velocity.y -= 20 * _delta
	_velocity = _body.move_and_slide(_velocity, Vector3.UP)
	_velocity.x *= friction
	_velocity.z *= friction
	return true

func move_leap(_delta:float, _speed:float) -> bool:
	var dir = _velocity.normalized()
	_velocity = dir * _speed
	_velocity = _body.move_and_slide(_velocity, Vector3.UP)
	return true

func start_leap(_delta:float, _speed:float) -> bool:
	var selfPos:Vector3 = _body.global_transform.origin
	moveYaw = ZqfUtils.yaw_between(selfPos, moveTargetPos)
	# _body.rotation.y = moveYaw
	var dir:Vector3 = Vector3()
	dir.x = -sin(moveYaw)
	dir.z = -cos(moveYaw)
	dir *= _speed
	_velocity = dir
	_velocity = _body.move_and_slide(_velocity, Vector3.UP)
	return true

func _hunt_ground(_delta:float) -> bool:
	if moveType == MobMoveType.Ground:
		_velocity.y -= 20 * _delta
		if !_body.is_on_floor():
			_velocity = _body.move_and_slide(_velocity, Vector3.UP)
			return true
	_tick -= _delta
	# var speed:float = 4.5
	_set_move_yaw(_calc_move_yaw())
	if _floorFront != null && !_floorFront.is_colliding():
		# print("No floor!")
		move_idle(_delta, 0.5)
		return true
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
	return true

func _hunt_flying(_delta:float) -> bool:
	# print("Hunt flying")
	_tick -= _delta
	_set_move_yaw(_calc_move_yaw())
	var move:Vector3 = Vector3()
	move.x = -sin(moveYaw)
	move.z = -cos(moveYaw)
	# calc y component
	# aim to float a little above target
	var diffY:float = moveTargetPos.y - (_body.global_transform.origin.y - 1)
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
	return true

func move_hunt(_delta:float) -> bool:
	if moveType == MobMoveType.Flying:
		return _hunt_flying(_delta)
	else:
		return _hunt_ground(_delta)

# func __process_not_run(_delta:float) -> void:
# 	_velocity.y -= 20 * _delta
# 	if _stunned || _isAttacking || _state == STATE_IDLE:
# 		move_idle(_delta)
# 		# # assume idle
# 		# _velocity = _body.move_and_slide(_velocity, Vector3.UP)
# 		# _velocity *= 0.95
# 	elif _state == STATE_HUNT:
# 		move_hunt(_delta)

