extends AITicker

@onready var _right:Node3D
@onready var _left:Node3D

var _aiTickInfo:AITickInfo = null

var _attackCount:int = 0
var _attackCycleCount:int = 0

func custom_init_b() -> void:
	_right = get_parent().get_node("head/right_cannon")
	_left = get_parent().get_node("head/left_cannon")

func _fire_attack(attack:MobAttack, tarPos:Vector3) -> void:
	# print("Lead velocity: " + str(_aiTickInfo.flatVelocity))

	# alternate leading shots with 'straight' shots
	#attack.prjPrefabOverride = Game.get_factory().prj_golem_t
	attack.prjPrefabOverride = Game.get_factory().prj_column_t
	var spinDegrees:float = 0.0

	var leadOffset:Vector3 = Vector3()

	# pick offset based on player movement
	if _aiTickInfo.flatVelocity.length_squared() > 0.1:
		leadOffset = _aiTickInfo.flatVelocity
	else:
		# just randomly pick left or right
		var toward:Vector3 = tarPos - _mob.global_transform.origin
		var right = toward.normalized().cross(Vector3.UP)
		if randf() > 0.5:
			leadOffset = right * 5
		else:
			var left:Vector3 = -right
			leadOffset = left * 5
	
	var leadPos:Vector3 = tarPos + leadOffset

	#var leadPos:Vector3 = tarPos + (_aiTickInfo.flatVelocity)
	if _attackCount % 2 == 0:
		_right.look_at(leadPos, Vector3.UP)
		_left.look_at(tarPos, Vector3.UP)
	else:
		_right.look_at(tarPos, Vector3.UP)
		_left.look_at(leadPos, Vector3.UP)
	
	attack.fire_from(tarPos, _right, 0.0)
	attack.fire_from(tarPos, _left, 0.0)

	_attackCount += 1

func _select_attack(_aiInfo:AITickInfo) -> int:
	_aiTickInfo = _aiInfo
	return super._select_attack(_aiInfo)
