extends Node

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
var _attackWindupTime:float = 0.5
var _attackRecoverTime:float = 0.5

func init(launchNode:Spatial, body:Spatial) -> void:
	_launchNode = launchNode
	_body = body

func start_attack(_targetPos:Vector3) -> void:
	_state = AttackState.Windup
	_tick = _attackWindupTime
	_launchNode.look_at(_targetPos, Vector3.UP)

# return false if attack has finished
func _update(_delta:float, _targetPos:Vector3) -> bool:
	if _state == AttackState.Attacking:
		return true
	elif _state == AttackState.Windup:
		return true
	elif _state == AttackState.Winddown:
		return true
	return false