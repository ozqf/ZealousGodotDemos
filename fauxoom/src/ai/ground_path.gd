extends Node
class_name GroundPath

var _pathTick:float = 0

var _pathProximityThreshold:float = 0.1

# protected
var agent:NavAgent = null
var _hasTarget:bool = true
var moveTargetPos:Vector3 = Vector3()

var direction:Vector3 = Vector3()

var positionSource:Spatial = null

# func _ready() -> void:
# 	agent = AI.create_nav_agent()

func ground_path_init(newAgent:NavAgent, source:Spatial) -> void:
	agent = newAgent
	positionSource = source

func _update_path() -> void:
	if !_hasTarget || positionSource == null:
		return
	agent.position = positionSource.global_transform.origin
	agent.target = moveTargetPos
	AI.get_path_for_agent(agent)
	if agent.pathNumNodes > 0:
		agent.pathIndex = 0
	else:
		agent.pathIndex = -1
#	print("Ground motor got " + str(agent.pathNumNodes) + " path nodes")

func _force_path_update() -> void:
	_pathTick = .5
	_update_path()

# return true if move is valid
func tick(_delta:float) -> bool:
	if _pathTick <= 0:
		_force_path_update()
	else:
		_pathTick -= _delta
	if agent.pathIndex == -1:
		return false
	if positionSource == null:
		return false
	var nodePos:Vector3 = agent.path[agent.pathIndex]
	var selfPos:Vector3 = positionSource.global_transform.origin
	if selfPos.distance_to(nodePos) < _pathProximityThreshold:
		# next node
		agent.pathIndex += 1
		# arrived?
		if agent.pathIndex >= agent.pathNumNodes:
			agent.hasPath = false
			agent.pathIndex = -1
			# drop out, no movement to perform
			return false
		nodePos = agent.path[agent.pathIndex]
	var towardPath:Vector3 = nodePos - selfPos
	towardPath = towardPath.normalized()
	# direction = moveTargetPos - selfPos
	direction = towardPath
	return true
	# _set_yaw_by_vector3(towardPath)
	# towardPath *= speed
	# _body.move_and_slide(towardPath, Vector3.UP)