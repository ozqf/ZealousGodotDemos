extends AITicker

var _spreadAtk:MobAttack

func custom_init_b() -> void:
	_spreadAtk = get_parent().find_node("delta_attack")

func _select_attack(_tickInfo:AITickInfo) -> int:
	var time:float = _mob.time
	if _check_attack_cooldown(_spreadAtk):
		_spreadAtk.lastSelectTime = time
		return _spreadAtk.index
	return ._select_attack(_tickInfo)
