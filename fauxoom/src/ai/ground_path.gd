extends Node
class_name GroundPath

const PATH_LIFETIME:float = 0.7

var _pathTick:float = 0

var _pathProximityThreshold:float = 0.1

# protected
var agent:NavAgent = null
var _hasTarget:bool = true
var _moveTargetPos:Vector3 = Vector3()

var direction:Vector3 = Vector3()

var positionSource:Node3D = null
var verbose:bool = false

# func _ready() -> void:
# 	agent = AI.create_nav_agent()

func set_target_position(pos:Vector3) -> void:
	var diff:Vector3 = _moveTargetPos - pos
	_moveTargetPos = pos
	if verbose:
		print("GroundPath updated dest: " + str(_moveTargetPos))
	if diff.length() >= 1.0:
		_force_path_update()

func get_node_count() -> int:
	return agent.path.size()

func get_node_pos_by_index(i:int) -> Vector3:
	if i >= agent.path.size():
		return Vector3()
	if i < 0:
		return Vector3()
	return agent.path[i]

func get_target_position() -> Vector3:
	return _moveTargetPos

func ground_path_init(newAgent:NavAgent, source:Node3D) -> void:
	agent = newAgent
	positionSource = source

func _update_path() -> void:
	if !_hasTarget || positionSource == null:
		return
	agent.position = positionSource.global_transform.origin
	agent.target = _moveTargetPos
	AI.get_path_for_agent(agent)
	if agent.pathNumNodes > 0:
		agent.pathIndex = 0
	else:
		agent.pathIndex = -1
#	print("Ground motor got " + str(agent.pathNumNodes) + " path nodes")

func _force_path_update() -> void:
	_pathTick = PATH_LIFETIME
	_update_path()

# return true if move is valid
func tick(_delta:float, stepDistance:float = 0) -> bool:
	if _pathTick <= 0:
		_force_path_update()
	else:
		_pathTick -= _delta
	if agent.pathIndex == -1:
		return false
	if positionSource == null:
		return false
	var proximityThreshold:float = _pathProximityThreshold
	if stepDistance > 0:
		proximityThreshold = stepDistance * 2.0
	var nodePos:Vector3 = agent.path[agent.pathIndex]
	var selfPos:Vector3 = positionSource.global_transform.origin
	if selfPos.distance_to(nodePos) < proximityThreshold:
		# next node
		agent.pathIndex += 1
		# arrived?
		if agent.pathIndex >= agent.pathNumNodes:
			if verbose:
				print("GroundPath reached end node " + str(agent.pathIndex))
			agent.hasPath = false
			agent.pathIndex = -1
			# drop out, no movement to perform
			return false
		if verbose:
			print("GroundPath Next node " + str(agent.pathIndex))
		nodePos = agent.path[agent.pathIndex]
	var towardPath:Vector3 = nodePos - selfPos
	towardPath = towardPath.normalized()
	# direction = _moveTargetPos - selfPos
	direction = towardPath
	return true
	# _set_yaw_by_vector3(towardPath)
	# towardPath *= speed
	# _body.move_and_slide(towardPath, Vector3.UP)
