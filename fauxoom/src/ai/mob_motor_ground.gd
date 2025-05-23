# Mob movement base class
extends MobMotor

@onready var _path:GroundPath = $ground_path

var _pathTick:float = 0

var _pathProximityThreshold:float = 0.1

func custom_init(body:CharacterBody3D) -> void:
	.custom_init(body)
	_path.ground_path_init(_agent, body)

func _update_path() -> bool:
	if !_hasTarget:
		return false
	_agent.position = _body.global_transform.origin
	_agent.target = moveTargetPos
	AI.get_path_for_agent(_agent)
	if _agent.pathNumNodes > 0:
		_agent.pathIndex = 0
		return true
	else:
		_agent.pathIndex = -1
		print("Ground motor got no path!")
		return false
#	print("Ground motor got " + str(_agent.pathNumNodes) + " path nodes")

func _force_path_update() -> void:
	_pathTick = .5
	_update_path()

func _pick_evade_point(_verbose:bool) ->Node3D:
	var r:float = randf()
	var p:Node3D = null
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
		_evadeTick = randf_range(1.5, 4)
		return p
	return null

func move_evade(_delta:float) -> bool:
	if _tick_evade_status(_delta):
		_evade_step(_delta)
	return true

func move_fall(_delta:float) -> bool:
	var move:Vector3 = Vector3(0, -20.0, 0)# * _delta
	_body.move_and_slide(move, Vector3.UP)
	return true

# returns true if successfully moved
func move_hunt(_delta:float) -> bool:
	_path.set_target_position(moveTargetPos)
	var selfPos:Vector3 = _body.global_transform.origin
	if !_path.tick(_delta):
		return false
	var towardPath:Vector3 = _path.direction
	# if _pathTick <= 0:
	# 	_force_path_update()
	# else:
	# 	_pathTick -= _delta
	# if _agent.pathIndex == -1:
	# 	return
	# var nodePos:Vector3 = _agent.path[_agent.pathIndex]
	# var selfPos:Vector3 = _body.global_transform.origin
	# if selfPos.distance_to(nodePos) < _pathProximityThreshold:
	# 	# next node
	# 	_agent.pathIndex += 1
	# 	# arrived?
	# 	if _agent.pathIndex >= _agent.pathNumNodes:
	# 		_agent.hasPath = false
	# 		_agent.pathIndex = -1
	# 		# drop out, no movement to perform
	# 		return
	# 	nodePos = _agent.path[_agent.pathIndex]
	# var towardPath:Vector3 = nodePos - selfPos
	# towardPath = towardPath.normalized()
	var towardTarget:Vector3 = moveTargetPos - selfPos
	_set_yaw_by_vector3(towardPath)
	towardPath *= speed
	_body.move_and_slide(towardPath, Vector3.UP)
	return true
