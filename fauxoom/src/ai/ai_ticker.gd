extends Spatial
class_name AITicker

const STATE_MOVE:int = 0
const STATE_WINDUP:int = 1
const STATE_ATTACK:int = 2
const STATE_WINDDOWN:int = 3

export var maxCycles:int = 1
export var faceTargetDuringWindup:bool = true

var _state:int = -1
var _tick:float = 0.0
var _cycles:int = 0

var _attackMode:int = 0

var lastTarPos:Vector3 = Vector3()

var _mob

func custom_init(mob) -> void:
	_mob = mob
	custom_init_b()

func custom_init_b() -> void:
	pass

func start_hunt() -> void:
	change_state(0)

func stop_hunt() -> void:
	pass

func change_state(newState:int) -> void:
	if newState == _state:
		return
	var oldState:int = _state
	_state = newState
	
	if custom_change_state(_state, oldState):
		return
	
	if _state == STATE_MOVE:
		_mob.sprite.play_animation("walk")
		_tick = 1
	elif _state == STATE_WINDUP:
		_mob.sprite.play_animation("aim")
		_tick = 0.25
	elif _state == STATE_ATTACK:
		_mob.sprite.play_animation("shoot")
		_mob.attack.fire(lastTarPos)
		_tick = 0.1
	elif _state == STATE_WINDDOWN:
		_mob.sprite.play_animation("aim")
		_tick = 0.25

# return true if state change was handled
# false to allow base function to handle it instead
func custom_change_state(_newState:int, _oldState:int) -> bool:
	return false

func custom_tick_state(_delta:float, _targetInfo:Dictionary) -> void:
	if _state == STATE_MOVE:
		_mob.motor.set_target(_targetInfo.position)
		if _targetInfo.trueDistance > 5:
			_mob.motor.move_hunt(_delta)
		if _tick <= 0 && _targetInfo.trueDistance <= 5:
			_cycles = 0
			lastTarPos = _targetInfo.position
			_mob.face_target_flat(lastTarPos)
			change_state(STATE_WINDUP)
	elif _state == STATE_WINDUP:
		_mob.motor.move_idle(_delta)
		if faceTargetDuringWindup:
			lastTarPos = _targetInfo.position
			_mob.face_target_flat(lastTarPos)
		if _tick <= 0:
			change_state(STATE_ATTACK)
	elif _state == STATE_ATTACK:
		_mob.motor.move_idle(_delta)
		# _mob.face_target_flat(_targetInfo.position)
		if _tick <= 0:
			_cycles += 1
			if _cycles < maxCycles:
				change_state(STATE_WINDUP)
				_tick = 0.02
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
	
