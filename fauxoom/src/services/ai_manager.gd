extends Spatial

onready var _testNavDest:Spatial = $test_nav_dest

# Other services
var _entRoot:Entities = null
var _navService:NavService = null

var _tacticNodes = []

# live player
var _player:Player = null

# cheats
var _noTarget:bool = false

var _emptyTargetInfo:Dictionary = {
	id = 0,
	position = Vector3(),
	yawDegrees = 0
}

# Called when the node enters the scene tree for the first time.
func _ready():
	print("AI singleton init")
	_entRoot = Ents
	add_to_group(Config.GROUP)
	add_to_group(Groups.CONSOLE_GROUP_NAME)
	add_to_group(Groups.GAME_GROUP_NAME)

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

func _process(_delta:float) -> void:
	var numNodes:int = _tacticNodes.size()
	for _i in range(0, numNodes):
		var n = _tacticNodes[_i]
		n.custom_update(_delta)

###############
# Registeration
###############

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
	print("AI singleton has " + str(_tacticNodes.size()) + " tactic nodes")

func deregister_tactic_node(tacticNode) -> void:
	var i:int = _tacticNodes.find(tacticNode)
	if i == -1:
		return
	_tacticNodes.remove(i)
	print("AI singleton has " + str(_tacticNodes.size()) + " tactic nodes")

###############
# Debugging
###############

func set_test_nav_dest(pos:Vector3) -> void:
	_testNavDest.global_transform.origin = pos

###############
# AI Queries
###############

func check_los_to_player(origin:Vector3) -> bool:
	if !_player:
		return false
	var dest = _player.get_targetting_info().position
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

func mob_check_target(_current:Dictionary) -> Dictionary:
	if !_player || _noTarget:
		return _emptyTargetInfo
	return _player.get_targetting_info()

func get_player_target() -> Dictionary:
	if !_player || _noTarget:
		return _emptyTargetInfo
	return _player.get_targetting_info()

func find_flee_position(_agent:Dictionary) -> bool:
	var resultNodeIndex:int = -1
	var resultNodePos:Vector3 = Vector3()
	var resultNodeDistSqr:float = 999999.0

	var from:Vector3 = _agent.position
	var numNodes:int = _tacticNodes.size()
	for _i in range(0, numNodes):
		var n = _tacticNodes[_i]
		# if can see player, not safe!
		if n.canSeePlayer:
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
