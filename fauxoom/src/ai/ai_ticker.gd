extends Spatial
class_name AITicker

const STATE_MOVE:int = 0
const STATE_WINDUP:int = 1
const STATE_ATTACK:int = 2
const STATE_WINDDOWN:int = 3
const STATE_REPEAT:int = 4

# state info read from attack when started
# var _maxCycles:int = 1
# var _faceTargetDuringWindup:bool = true

var _stats:MobStats

var _state:int = -1
var _tick:float = 0.0
var _cycles:int = 0
var isSniper:bool = false

var _attackIndex:int = -1
var _attackMode:int = 0
var _revengeAttack:bool = false

var lastTarPos:Vector3 = Vector3()

var _mob

func custom_init(mob, stats:MobStats) -> void:
	_mob = mob
	_stats = stats
	custom_init_b()

func custom_init_b() -> void:
	pass

func get_attack() -> MobAttack:
	return _mob.attacks[_attackIndex]

func start_hunt() -> void:
	change_state(0)
	if _revengeAttack:
		# end move think immediately and try to attack
		# next tick
		_tick = 0
		_revengeAttack = false

func stop_hunt() -> void:
	pass

func stun_ended() -> void:
	_revengeAttack = true

func change_state(newState:int) -> void:
	if newState == _state:
		return
	var oldState:int = _state
	_state = newState
	
	if custom_change_state(_state, oldState):
		return
	
	if _state == STATE_MOVE:
		_mob.sprite.play_animation("walk")
		_tick = _stats.moveTime
	elif _state == STATE_WINDUP:
		_mob.sprite.play_animation("aim")
		_tick = get_attack().windUpTime
	elif _state == STATE_ATTACK:
		_mob.sprite.play_animation("shoot")
		_mob.attacks[_attackIndex].fire(lastTarPos) 
		_tick = get_attack().attackAnimTime
	elif _state == STATE_WINDDOWN:
		_mob.sprite.play_animation("aim")
		_tick = get_attack().windDownTime

# return true if state change was handled
# false to allow base function to handle it instead
func custom_change_state(_newState:int, _oldState:int) -> bool:
	return false

func _start_attack(_delta:float, _targetInfo:Dictionary) -> void:
	_attackIndex = _select_attack(_targetInfo)
	if _attackIndex < 0:
		return
	# maxCycles = _mob.attacks[_attackIndex].attackCount
	_cycles = 0
	lastTarPos = _targetInfo.position
	_mob.face_target_flat(lastTarPos)
	change_state(STATE_WINDUP)

func _select_attack(_targetInfo:Dictionary) -> int:
	var dist:float = _targetInfo.trueDistance
	var numAttacks:int = _mob.attacks.size()
	for _i in range (0, numAttacks):
		var att:MobAttack = _mob.attacks[_i]
		if dist < att.minUseRange:
			continue
		elif dist > att.maxUseRange:
			continue
		return _i
	return -1

func set_rotation_to_movement() -> void:
	_mob.sprite.yawDegrees = rad2deg(_mob.motor.moveYaw)

func set_rotation_to_target(pos:Vector3) -> void:
	var yawDegrees:float = ZqfUtils.yaw_between(_mob.global_transform.origin, pos)
	yawDegrees = rad2deg(yawDegrees)
	_mob.sprite.yawDegrees = yawDegrees

func custom_tick_state(_delta:float, _targetInfo:Dictionary) -> void:
	if _state == STATE_MOVE:
		if isSniper:
			_start_attack(_delta, _targetInfo)
			return
		_mob.motor.set_target(_targetInfo.position)
		if _targetInfo.trueDistance > 5:
			_mob.motor.move_hunt(_delta)
			set_rotation_to_movement()
		if _tick <= 0 && _targetInfo.trueDistance <= 25:
			_start_attack(_delta, _targetInfo)
			set_rotation_to_target(_targetInfo.position)
	
	elif _state == STATE_WINDUP:
		_mob.motor.move_idle(_delta)
		if get_attack().faceTargetDuringWindup:
			lastTarPos = _targetInfo.position
			_mob.face_target_flat(lastTarPos)
		if _tick <= 0:
			change_state(STATE_ATTACK)
	elif _state == STATE_ATTACK:
		_mob.motor.move_idle(_delta)
		# _mob.face_target_flat(_targetInfo.position)
		if _tick <= 0:
			_cycles += 1
			if _cycles < get_attack().attackCount:
				change_state(STATE_WINDUP)
				_tick = get_attack().repeatTime
			else:
				change_state(STATE_WINDDOWN)
	elif _state == STATE_WINDDOWN:
		_mob.motor.move_idle(_delta)
		if _tick <= 0:
			change_state(STATE_MOVE)
	else:
		change_state(STATE_MOVE)

func custom_tick(_delta:float, _targetInfo:Dictionary) -> void:
	_tick -= _delta
	custom_tick_state(_delta, _targetInfo)
	
