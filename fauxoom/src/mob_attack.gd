extends Node

var _prj_point_t = load("res://prefabs/dynamic_entities/prj_point.tscn")

enum AttackState {
	Idle,
	Windup,
	Attacking,
	Winddown
}
var _state = AttackState.Idle

var _launchNode:Spatial = null
var _body:Spatial = null

var _tick:float = 0
var _attackWindupTime:float = 0.3 # 0.5
var _attackRecoverTime:float = 0.3 # 0.5
var _prjMask:int = -1

func custom_init(launchNode:Spatial, body:Spatial) -> void:
	_launchNode = launchNode
	_body = body
	_prjMask = Interactions.get_enemy_prj_mask()

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

func _fire(target:Vector3) -> void:
	# print("Fire!")
	var prj = _prj_point_t.instance()
	Game.get_dynamic_parent().add_child(prj)
	var selfPos:Vector3 = _launchNode.global_transform.origin
	var forward:Vector3 = Vector3()
	forward.x = target.x - selfPos.x
	forward.y = target.y - selfPos.y
	forward.z = target.z - selfPos.z
	#var diff:Vector3 = target - selfPos
	prj.launch(selfPos, forward.normalized(), _body, _prjMask)

# return false if attack has finished
func custom_update(_delta:float, _targetPos:Vector3) -> bool:
	if _state == AttackState.Attacking:
		_fire(_targetPos)
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
