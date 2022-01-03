extends Spatial

const Enums = preload("res://src/enums.gd")

const CAN_SEE_PLAYER_FLAG:int = (1 << 0)
const CANNOT_SEE_PLAYER_FLAG:int = (1 << 1)
const SNIPER_FLAG:int = (1 << 2)
const VULNERABLE_FLAG:int = (1 << 3)
const OCCUPIED_FLAG:int = (1 << 4)

var verboseMobs:bool = false

var _navAgent_t = preload("res://src/defs/nav_agent.gd")
var _aiTickInfo_t = preload("res://src/defs/ai_tick_info.gd")

onready var _testNavDest:Spatial = $test_nav_dest

# Other services
var _entRoot:Entities = null
var _navService:NavService = null
var _influenceMap = null

# TODO: Nodes should be set as active/inactive via their tag to 
# reduce the current search space to only those that are necessary.
# update the tactic nodes list when this changes.

# specially placed AI nodes
var _tacticNodes = []
var _inactiveTacticNodes = []

# live player
var _player:Player = null

var _mobs = []
var _numRoleCharge:int = 0
var _numRoleSnipe:int = 0

# cheats/debugging
var _noTarget:bool = false
var _point_t = preload("res://prefabs/point_gizmo.tscn")
var _debugPathPoints = []

var _activeTag:int = 0

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

func write_save_dict() -> Dictionary:
	return {
		activeTag = _activeTag
	}

func load_save_dict(_dict:Dictionary) -> void:
	activate_waypoint_tag(_dict.activeTag)

func _process(_delta:float) -> void:
	if _player == null:
		return
	if !is_instance_valid(_player):
		# may hit this during level restarts, stale reference
		# to old player instance.
		# also triggered by end of level or other situations
		# that despawn the player
		# print("Skipped ai node update - Invalid player")
		return
	var numNodes:int = _tacticNodes.size()
	for _i in range(0, numNodes):
		var n = _tacticNodes[_i]
		n.custom_update(_delta)

func get_debug_text() -> String:
	var txt:String = "--- AI Manager ---";
	txt += "\nTotal nodes " + str(_inactiveTacticNodes.size())
	txt += "\nActive Nodes: " + str(_tacticNodes.size())
	txt += "\nSquad size: " + str(_mobs.size())
	txt += "\nNum chargers: " + str(_numRoleCharge)
	txt += "\nNum snipers: " + str(_numRoleSnipe)
	var occupiedCount:int = 0
	for i in range(0, _tacticNodes.size()):
		var n = _tacticNodes[i]
		if (n.flags & OCCUPIED_FLAG) != 0:
			occupiedCount += 1
	txt += "\nOccupied nodes: " + str(occupiedCount) + ""
	txt += "\nSnipe nodes:\n"
	for i in range(0, _tacticNodes.size()):
		var n = _tacticNodes[i]
		if (n.flags & SNIPER_FLAG) == 0:
			continue
		txt += n.get_debug_string()
	return txt

###############
# Roles
###############

func tally_mob_roles() -> void:
	_numRoleSnipe = 0
	_numRoleCharge = 0
	for i in range(0, _mobs.size()):
		var mob = _mobs[i]
		if mob.roleId == Enums.CombatRole.Ranged:
			_numRoleSnipe += 1
		else:
			_numRoleCharge += 1

###############
# Registration
###############

func create_nav_agent() -> NavAgent:
	return _navAgent_t.new()

func create_tick_info() -> AITickInfo:
	return _aiTickInfo_t.new()

# must call when a mob is spawned so it can be part of the squad
func register_mob(mob) -> void:
	# tally before we add this new mob, so we can give it a suitable role:
	tally_mob_roles()
	_mobs.push_back(mob)
	# for testing snipers, assign everyone that role
#	mob.roleId = 1
#	_numRoleSnipe += 1

	# if melee we can't assign as a sniper so just assign away
	if mob.roleClass == Enums.EnemyRoleClass.Melee:
		mob.roleId = 0
		_numRoleCharge += 1
		return
	# try to distribute evenly
	if _numRoleSnipe < _numRoleCharge:
		mob.roleId = Enums.CombatRole.Ranged
		_numRoleSnipe += 1
	else:
		mob.roleId = Enums.CombatRole.Assault
		_numRoleCharge += 1

func clear_agent_node(agent:NavAgent) -> void:
	var n:AITacticNode = agent.objectiveNode
	if n != null && is_instance_valid(n) && n.assignedAgent != null && n.assignedAgent == agent:
		print("Unassigning tactic node " + str(n.index))
		n.assignedAgent = null
		n.flags &= ~OCCUPIED_FLAG

# must call when a mob dies/is removed in any way!
func deregister_mob(mob) -> void:
	var i:int = _mobs.find(mob)
	if i != -1:
		_mobs.remove(i)
	# check for and unmark from assigned waypoint
	var agent = mob.motor.get_agent()
	clear_agent_node(agent)

	# retally roles and maybe reassign someone
	tally_mob_roles()

func register_nav_service(_newNavService:NavService) -> void:
	_navService = _newNavService
	print("Registered nav service")

func deregister_nav_service(_newNavService:NavService) -> void:
	_navService = null

func register_tactic_node(newTacticNode) -> void:
	# ZqfUtils.array_add_safe(_tacticNodes, newTacticNode)
	ZqfUtils.array_add_safe(_inactiveTacticNodes, newTacticNode)

func deregister_tactic_node(objectiveNode) -> void:
	ZqfUtils.array_remove_safe(_tacticNodes, objectiveNode)
	ZqfUtils.array_remove_safe(_inactiveTacticNodes, objectiveNode)

func influence_register_map(newInfluenceMap) -> void:
	_influenceMap = newInfluenceMap
	print("AI Manager got influence map")

func influence_deregister_map(newInfluenceMap) -> void:
	if _influenceMap == newInfluenceMap:
		_influenceMap = null
		print("AI Manager removed influence map")

func hide_all_nodes() -> void:
	var count:int = _inactiveTacticNodes.size()
	for i in range(0, count):
		_inactiveTacticNodes[i].visible = false

func activate_waypoint_tag(tag:int) -> void:
	print("Activate waypoint tag " + str(tag))
	_activeTag = tag
	_tacticNodes.clear()
	hide_all_nodes()
	if tag == 0:
		return
	var count:int = _inactiveTacticNodes.size()
	for i in range(0, count):
		var n = _inactiveTacticNodes[i]
		if n.tag == tag:
			_tacticNodes.push_back(n)
			n.visible = true

func deactivate_waypoint_tag(tag:int) -> void:
	print("Deactivate waypoint tag " + str(tag))
	_tacticNodes.clear()
	hide_all_nodes()
	if tag == 0:
		return

###############
# Debugging
###############

func set_test_nav_dest(pos:Vector3) -> void:
	_testNavDest.global_transform.origin = pos

func give_to_player(item:String, amount:int) -> int:
	if _player == null:
		return 0
	return _player.give_item(item, amount)

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
		# print("Agent path has " + str(agent.pathNumNodes) + " nodes")
		pass
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

# mask bits must be on. mask filter bits must be off
func _find_closest_node(_agent:NavAgent, mask:int, filter:int, closest:bool) -> bool:
	# print("Find closest node. Mask " + str(mask) + " filter " + str(filter))
	var resultNodeIndex:int = -1
	var resultNodePos:Vector3 = Vector3()
	var resultNodeDistSqr:float = 999999.0

	var from:Vector3 = _agent.position
	var numNodes:int = _tacticNodes.size()
	for _i in range(0, numNodes):
		var n = _tacticNodes[_i]
		if (n.flags & mask) == 0:
			continue
		if (n.flags & filter) != 0:
#			print("node filter flags mismatch. Flags: " + str(n.flags) + " filter: " + str(filter))
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
			var better:bool = false
			if closest:
				if candidateDistSqr < resultNodeDistSqr:
					better = true
			else:
				if candidateDistSqr > resultNodeDistSqr:
					better = true
			if better:
				# print("Replacing " + str(resultNodeIndex) + " with " + )
				resultNodeIndex = _i
				resultNodePos = candidatePos
				resultNodeDistSqr = candidateDistSqr

	if resultNodeIndex == -1:
		# _agent.nodeIndex = -1
		_agent.objectiveNode = null
		return false
	else:
		# _agent.nodeIndex = resultNodeIndex
		_agent.target = resultNodePos
		_agent.objectiveNode = _tacticNodes[resultNodeIndex]
		return true

func find_flee_position(_agent:NavAgent) -> bool:
	clear_agent_node(_agent)
	var result:bool = _find_closest_node(_agent, CANNOT_SEE_PLAYER_FLAG, OCCUPIED_FLAG, false)
	if _agent.objectiveNode != null:
		_agent.objectiveNode.flags |= OCCUPIED_FLAG
	return result

func find_melee_position(_agent:NavAgent) -> bool:
	clear_agent_node(_agent)
	return _find_closest_node(_agent, CAN_SEE_PLAYER_FLAG, 0, true)

func find_sniper_position(_agent:NavAgent) -> bool:
	clear_agent_node(_agent)
	var result:bool = _find_closest_node(_agent, SNIPER_FLAG, OCCUPIED_FLAG, false)
	if _agent.objectiveNode != null:
		_agent.objectiveNode.flags |= OCCUPIED_FLAG
		_agent.objectiveNode.assignedAgent = _agent
		# print("Node " + _agent.objectiveNode.name + " now occupied. Bits: " + ZqfUtils.bits_to_string(_agent.objectiveNode.flags))
	return result
