extends AITicker

func custom_init_b() -> void:
	print("Pinkie init")

# func custom_change_state(_newstate, _oldState):
# 	if _newstate == STATE_WINDUP:
# 		# print("Pinkie attack! change state")
# 		_tick = 1
# 		_state = STATE_MOVE
# 		return true
# 	return false

# func custom_tick(_delta:float, _targetInfo:Dictionary) -> void:
# 	_tick -= _delta
# 	_mob.motor.set_move_target(_targetInfo.position)
# 	_mob.motor.move_hunt(_delta)
