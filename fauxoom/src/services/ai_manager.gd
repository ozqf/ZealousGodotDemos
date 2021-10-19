extends Spatial

var _navAgent_t = preload("res://src/defs/nav_agent.gd")
var _aiTickInfo_t = preload("res://src/defs/ai_tick_info.gd")

onready var _testNavDest:Spatial = $test_nav_dest

# Other services
var _entRoot:Entities = null
var _navService:NavService = null
var _influenceMap = null

# specially placed AI nodes
var _tacticNodes = []

# live player
var _player:Player = null

# cheats/debugging
var _noTarget:bool = false
var _point_t = preload("res://prefabs/point_gizmo.tscn")
var _debugPathPoints = []

var _emptyTargetInfo:Dictionary = {
	id = 0,
	position = Vector3(),
	yawDegrees = 0
}

# Called when the node enters the scene tree for the first time.
func _ready():
	print("AI singleton init")
	_entRoot = Ents
	_testNavDest.visible = false
	add_to_group(Config.GROUP)
	add_to_group(Groups.CONSOLE_GROUP_NAME)
	add_to_group(Groups.GAME_GROUP_NAME)
	add_to_group(Groups.INFLUENCE_GROUP)

func console_on_exec(_txt: String, _tokens:PoolStringArray) -> void:
	if _txt == "ainodes":
		print("=== AI Nodes ===")
		for _i in range(0, _tacticNodes.size()):
			var n = _tacticNodes[_i]
			print(str(_i) + " Can see player " + str(n.canSeePlayer) + " dist: " + str(n.distToPlayer))

func game_on_player_spawned(player) -> void:
	print("AI singleton - got player")
	_player = player

func game_on_player_died(_info:Dictionary) -> void:
	if _player != null:
		_player = null

# clear any player info or a stale player record can be 
# read by ai
func game_on_map_change() -> void:
	print("AI manager - map change clear player")
	_player = null

func _process(_delta:float) -> void:
	if _player == null:
		return
	if !is_instance_valid(_player):
		# may hit this during level restarts, stale reference
		# to old player instance
		print("Skipped ai node update - Invalid player")
		return
	var numNodes:int = _tacticNodes.size()
	for _i in range(0, numNodes):
		var n = _tacticNodes[_i]
		n.custom_update(_delta)

###############
# Registeration
###############

func create_nav_agent() -> NavAgent:
	return _navAgent_t.new()

func create_tick_info() -> AITickInfo:
	return _aiTickInfo_t.new()

func register_nav_service(_newNavService:NavService) -> void:
	_navService = _newNavService
	print("Registered nav service")

func deregister_nav_service(_newNavService:NavService) -> void:
	_navService = null

func register_tactic_node(newTacticNode) -> void:
	var i:int = _tacticNodes.find(newTacticNode)
	if i != -1:
		return
	_tacticNodes.push_back(newTacticNode)
#	print("AI singleton has " + str(_tacticNodes.size()) + " tactic nodes")

func deregister_tactic_node(tacticNode) -> void:
	var i:int = _tacticNodes.find(tacticNode)
	if i == -1:
		return
	_tacticNodes.remove(i)
#	print("AI singleton has " + str(_tacticNodes.size()) + " tactic nodes")

func influence_register_map(newInfluenceMap) -> void:
	_influenceMap = newInfluenceMap
	print("AI Manager got influence map")

func influence_deregister_map(newInfluenceMap) -> void:
	if _influenceMap == newInfluenceMap:
		_influenceMap = null
		print("AI Manager removed influence map")

###############
# Debugging
###############

func set_test_nav_dest(pos:Vector3) -> void:
	_testNavDest.global_transform.origin = pos

###############
# Navigation Queries
###############

func find_closest_navmesh_point(to:Vector3) -> Vector3:
	if _navService == null:
		return Vector3()
	return _navService.get_closest_point(to)

func get_path_to_point(from:Vector3, to:Vector3) -> PoolVector3Array:
	if _navService == null:
		return PoolVector3Array()
	return _navService.get_simple_path(from, to)

func get_path_for_agent(agent:NavAgent) -> bool:
	if _navService == null:
		agent.hasPath = false
		agent.path = []
		return false
	agent.path = _navService.get_simple_path(agent.position, agent.target)
	agent.pathNumNodes = agent.path.size()
	if agent.pathNumNodes == 0:
		print("Agent path has zero nodes from " + str(agent.position) + " to " + str(agent.target))
	else:
		print("Agent path has " + str(agent.pathNumNodes) + " nodes")
	for _i in range(0, agent.pathNumNodes):
		agent.path[_i].y -= 0.4
	# debug_path(agent.path)
	return true

func debug_path(path:PoolVector3Array) -> void:
	# clear current nodes
	for i in range(0, _debugPathPoints.size()):
		_debugPathPoints[i].queue_free()
	_debugPathPoints.clear()
	
	print("Path: " + str(path.size()) + " nodes")
	var previous = null
	for i in range(0, path.size()):
		print(str(path[i]))
		var pointObj = _point_t.instance()
		add_child(pointObj)
		pointObj.global_transform.origin = path[i]
		_debugPathPoints.push_back(pointObj)
		if previous != null && previous.global_transform.origin != path[i]:
			previous.look_at(path[i], Vector3.UP)
		previous = pointObj

###############
# AI Queries
###############

func check_los_to_player(origin:Vector3) -> bool:
	if !_player:
		return false
	var info = _player.get_targetting_info()
	if !info:
		return false
	var dest = info.position
	var playerOffset:Vector3 = Vector3(0, 0.5, 0)
	origin = origin + playerOffset
	return ZqfUtils.los_check(_entRoot, origin, dest, 1)

func get_distance_to_player(origin:Vector3) -> float:
	if !_player:
		return 999999.0
	return ZqfUtils.distance_between(origin, _player.global_transform.origin)

func check_player_in_front(origin:Vector3, yawDegrees:float) -> bool:
	if !_player:
		return false
	var dest = _player.get_targetting_info().position
	var yawToPlayer:float = rad2deg(ZqfUtils.yaw_between(dest, origin))
	yawDegrees = ZqfUtils.cap_degrees(yawDegrees - 90)
	yawToPlayer = ZqfUtils.cap_degrees(yawToPlayer)
	# var diff1:float = yawToPlayer - yawDegrees
	var diff2:float = yawDegrees - yawToPlayer
	# print("Mob yaw " + str(yawDegrees) + " vs to player angle " + str(yawToPlayer))
	# print("  Diff1: " + str(diff1) + " diff2: " + str(diff2))
	if diff2 >= 0 && diff2 <= 180:
		return true
	return false

func mob_check_target_old(_current:Spatial) -> Spatial:
	if !_player:
		return null
	return _player as Spatial

func mob_check_target() -> Dictionary:
	if !_player || _noTarget || !is_instance_valid(_player):
		return _emptyTargetInfo
	return _player.get_targetting_info()

func get_player_target() -> Dictionary:
	if !is_instance_valid(_player) || _noTarget:
		return _emptyTargetInfo
	return _player.get_targetting_info()

func _find_closest_node(_agent:NavAgent, canSeePlayer:bool) -> bool:
	var resultNodeIndex:int = -1
	var resultNodePos:Vector3 = Vector3()
	var resultNodeDistSqr:float = 999999.0

	var from:Vector3 = _agent.position
	var numNodes:int = _tacticNodes.size()
	for _i in range(0, numNodes):
		var n = _tacticNodes[_i]
		# if can see player, not safe!
		if n.canSeePlayer != canSeePlayer:
			# print(str(_i) + " cannot see player - skipping")
			continue
		var candidatePos:Vector3 = n.global_transform.origin
		var candidateDistSqr:float = ZqfUtils.distance_between_sqr(from, candidatePos)
		if resultNodeIndex == -1:
			# first valid node
			resultNodeIndex = _i
			resultNodePos = candidatePos
			resultNodeDistSqr = candidateDistSqr
		else:
			# compare distance with current result - favour nearest
			if candidateDistSqr < resultNodeDistSqr:
				# print("Replacing " + str(resultNodeIndex) + " with " + )
				resultNodeIndex = _i
				resultNodePos = candidatePos
				resultNodeDistSqr = candidateDistSqr

	if resultNodeIndex == -1:
		_agent.nodeIndex = -1
		return false
	else:
		_agent.nodeIndex = resultNodeIndex
		_agent.target = resultNodePos
		return true

func find_flee_position(_agent:NavAgent) -> bool:
	return _find_closest_node(_agent, false)

func find_melee_position(_agent:NavAgent) -> bool:
	return _find_closest_node(_agent, true)
