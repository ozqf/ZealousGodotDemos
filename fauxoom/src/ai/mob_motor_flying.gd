extends MobMotor

func _evade_step(_delta:float) -> void:
	var from:Vector3 = _body.global_transform.origin
	var to:Vector3 = _evadeTarget.global_transform.origin

	# make sure move is flat!
	to.y = from.y
	# psyche. we're a flying enemy. go up!
	var heightDiff:float = from.y - moveTargetPos.y
	if heightDiff < 3:
		to.y += 1.0
		#print("Height diff " + str(heightDiff) + " from self: " + str(from.y) + " target: " + str(moveTargetPos.y))
	var toward:Vector3 = to - from
	toward = toward.normalized()
	_body.move_and_slide(toward * 4)

	# face move (attack) target
	var towardTarget:Vector3 = moveTargetPos - from
	from.y = moveTargetPos.y
	_set_yaw_by_vector3(towardTarget.normalized())

func move_evade(_delta:float) -> void:
	if _tick_evade_status(_delta):
		_evade_step(_delta)

func move_hunt(_delta:float) -> void:
	var turnMul:float = _delta * 2.0
	var tarPos:Vector3 = moveTargetPos
	var pos:Vector3 = global_transform.origin
	var toward:Vector3 = (tarPos - pos).normalized()
	var dir:Vector3 = _velocity.normalized()
	var newDir:Vector3 = (dir + (toward * turnMul)).normalized()
	_velocity = newDir * speed
	_velocity = _body.move_and_slide(_velocity)
