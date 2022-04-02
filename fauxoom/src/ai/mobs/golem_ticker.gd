extends AITicker

onready var _right:Spatial
onready var _left:Spatial

var _aiTickInfo:AITickInfo = null

var _attackCount:int = 0
var _attackCycleCount:int = 0

func custom_init_b() -> void:
	_right = get_parent().get_node("head/right_cannon")
	_left = get_parent().get_node("head/left_cannon")

func _fire_attack(attack:MobAttack, tarPos:Vector3) -> void:
	# print("Lead velocity: " + str(_aiTickInfo.flatVelocity))

	# alternate leading shots with 'straight' shots
	attack.prjPrefabOverride = Game.prj_golem_t
	if _attackCount % 2 == 0:
		var leadPos:Vector3 = tarPos + (_aiTickInfo.flatVelocity)
		_right.look_at(leadPos, Vector3.UP)
		_left.look_at(leadPos, Vector3.UP)
	else:
		_right.look_at(tarPos, Vector3.UP)
		_left.look_at(tarPos, Vector3.UP)
	attack.fire_from(tarPos, _right)
	attack.fire_from(tarPos, _left)

	_attackCount += 1

func _select_attack(_tickInfo:AITickInfo) -> int:
	_aiTickInfo = _tickInfo
	return ._select_attack(_tickInfo)
