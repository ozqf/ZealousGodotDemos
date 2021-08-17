extends Node
class_name MobAttack

var _prj_point_t = load("res://prefabs/dynamic_entities/prj_point.tscn")

export var minUseRange:float = 0
export var maxUseRange:float = 9999
export var attackCount:int = 1

export var windUpTime:float = 0.25
export var windDownTime:float = 0.25
export var repeatTime:float = 0.1
export var attackAnimTime:float = 0.1

# TODO - implement attack cooldowns
# make this attack unusable for the duration, and other attacks
# must be used instead. Stops enemies from spamming powerful attacks
export var cooldown:float = 0
# limits number of times this mob can fire this attack
export var ammo:int = -1

export var faceTargetDuringWindup:bool = true

enum AttackState {
	Idle,
	Windup,
	Attacking,
	Winddown
}
var _state = AttackState.Idle

var _launchNode:Spatial = null
var _body:Spatial = null
var _pattern:Pattern = null

var _tick:float = 0
var _repeats:int = 1
var _attackWindupTime:float = 0.3 # 0.5
var _attackRecoverTime:float = 0.3 # 0.5
var _prjMask:int = -1

var _patternBuffer

func custom_init(launchNode:Spatial, body:Spatial) -> void:
	_launchNode = launchNode
	_body = body
	_prjMask = Interactions.get_enemy_prj_mask()
	_pattern = get_node_or_null("pattern") as Pattern
	# allocate buffer for pattern if necessary
	if _pattern != null:
		_patternBuffer = []
		for _i in range(0, 100):
			_patternBuffer.push_back({
				pos = Vector3(),
				forward = Vector3()
			})

func _tick_down(_delta:float) -> bool:
	_tick -= _delta
	return (_tick <= 0)

func is_running() -> bool:
	return (_state != AttackState.Idle)

# returns false if attack cannot start for some reason...
func start_attack(_targetPos:Vector3) -> bool:
	# print("Start attack")
	_state = AttackState.Windup
	_tick = _attackWindupTime
	_launchNode.look_at(_targetPos, Vector3.UP)
	return true

func cancel() -> void:
	_state = AttackState.Idle

func fire(target:Vector3) -> void:
	# print("Fire!")
	
	var selfPos:Vector3 = _launchNode.global_transform.origin
	var forward:Vector3 = Vector3()
	forward.x = target.x - selfPos.x
	forward.y = target.y - selfPos.y
	forward.z = target.z - selfPos.z
	forward = forward.normalized()

	if _pattern == null:
		var prj = _prj_point_t.instance()
		Game.get_dynamic_parent().add_child(prj)
		prj.launch_prj(selfPos, forward, 0, Interactions.TEAM_ENEMY, _prjMask)
		return
	var numItems:int = 0
	numItems = _pattern.fill_items(selfPos, forward, _patternBuffer, numItems)
	print("Pattern attack got " + str(numItems) + " items")
	for _i in range (0, numItems):
		var item:Dictionary = _patternBuffer[_i]
		var prj = _prj_point_t.instance()
		Game.get_dynamic_parent().add_child(prj)
		prj.launch_prj(item.pos, item.forward, 0, Interactions.TEAM_ENEMY, _prjMask)

	# for _i in range(0, _pattern.count):
	# 	var offset:Vector3 = _pattern.get_random_offset()
	# 	var pos = selfPos + offset
	# 	print("Shoot pos " + str(pos) + " offset " + str(offset))
	# 	var prj = _prj_point_t.instance()
	# 	Game.get_dynamic_parent().add_child(prj)
	# 	prj.launch_prj(pos, forward.normalized(), 0, Interactions.TEAM_ENEMY, _prjMask)

# return false if attack has finished
func atk_custom_update(_delta:float, _targetPos:Vector3) -> bool:
	if _state == AttackState.Attacking:
		fire(_targetPos)
		_tick = _attackRecoverTime
		_state = AttackState.Winddown
	elif _state == AttackState.Windup:
		if _tick_down(_delta):
			_state = AttackState.Attacking
	elif _state == AttackState.Winddown:
		if _tick_down(_delta):
			_state = AttackState.Idle
			return false
	else:
		return false
	return true
