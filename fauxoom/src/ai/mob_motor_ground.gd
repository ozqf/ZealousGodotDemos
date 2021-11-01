# Mob movement base class
extends MobMotor

var _pathTick:float = 0

var _pathProximityThreshold:float = 0.1

var _evading:bool = false
var _evadeTarget:Spatial = null 

func custom_init(body:KinematicBody) -> void:
	.custom_init(body)

func _update_path() -> void:
	if !_hasTarget:
		return
	_agent.position = _body.global_transform.origin
	_agent.target = _target
	AI.get_path_for_agent(_agent)
	if _agent.pathNumNodes > 0:
		_agent.pathIndex = 0
	else:
		_agent.pathIndex = -1
#	print("Ground motor got " + str(_agent.pathNumNodes) + " path nodes")

func force_path_update() -> void:
	_pathTick = .5
	_update_path()

func pick_evade_point(_verbose:bool) -> Spatial:
	var r:float = randf()
	var p:Spatial = null
	if _floorLeft.isValid:
		if _floorRight.isValid:
			# pick a direction
			if r > 0.5:
				p = _floorLeft
			else:
				p = _floorRight
		else:
			# only one option!
			p = _floorLeft
	else:
		p = _floorRight
	if p != null:
		if _verbose:
			print("Mob evade to " + p.name)
		_evadeTick = rand_range(1.5, 4)
		return p
	return null

var _evadeTick:float = 0.0

func _evade_step(_delta:float) -> void:
	var from:Vector3 = _body.global_transform.origin
	var to:Vector3 = _evadeTarget.global_transform.origin
	# make sure move is flat!
	to.y = from.y
	var toward:Vector3 = to - from
	toward = toward.normalized()
	_body.move_and_slide(toward * 4)

	# face move (attack) target
	var towardTarget:Vector3 = _target - from
	from.y = _target.y
	_set_yaw_by_vector3(towardTarget.normalized())

func move_evade(_delta:float) -> void:
	_evadeTick -= _delta
	if _evadeTarget != null:
		if !_evadeTarget.isValid:
			_evadeTarget = pick_evade_point(false)
		elif _evadeTick <= 0.0 && randf() > 0.5:
			_evadeTarget = pick_evade_point(false)
	else:
		_evadeTarget = pick_evade_point(false)
		if _evadeTarget == null:
			# we can't move :(
			print(name + " has no evade target")
			return
	_evade_step(_delta)

func move_hunt(_delta:float) -> void:
	if _pathTick <= 0:
		force_path_update()
	else:
		_pathTick -= _delta
	if _agent.pathIndex == -1:
		return
	var nodePos:Vector3 = _agent.path[_agent.pathIndex]
	var selfPos:Vector3 = _body.global_transform.origin
	if selfPos.distance_to(nodePos) < _pathProximityThreshold:
		# next node
		_agent.pathIndex += 1
		# arrived?
		if _agent.pathIndex >= _agent.pathNumNodes:
			_agent.hasPath = false
			_agent.pathIndex = -1
			# drop out, no movement to perform
			return
		nodePos = _agent.path[_agent.pathIndex]
	var towardPath:Vector3 = nodePos - selfPos
	towardPath = towardPath.normalized()
	var towardTarget:Vector3 = _target - selfPos
	_set_yaw_by_vector3(towardTarget)
	towardPath *= speed
	_body.move_and_slide(towardPath, Vector3.UP)
