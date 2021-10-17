# Mob movement base class
extends MobMotor

var _agent:NavAgent = null

var _pathTick:float = 0

var _pathProximityThreshold:float = 0.1

func custom_init(body:KinematicBody) -> void:
	.custom_init(body)
	_agent = AI.create_nav_agent()

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
	print("Ground motor got " + str(_agent.pathNumNodes) + " path nodes")

func move_hunt(_delta:float) -> void:
	if _pathTick <= 0:
		_pathTick = 1.5
		_update_path()
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
	var toward:Vector3 = nodePos - selfPos
	toward = toward.normalized()
	toward *= 5
	_body.move_and_slide(toward, Vector3.UP)
