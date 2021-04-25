extends Spatial
class_name AITicker

# var _body:KinematicBody
# var _head:Spatial
# var _sprite:CustomAnimator3D
var _mob

var _state:int = -1
var _tick:float = 0.0

var lastTarPos:Vector3 = Vector3()

func custom_init(mob) -> void:
	_mob = mob

func start_hunt() -> void:
	change_state(0)

func stop_hunt() -> void:
	pass

func change_state(newState:int) -> void:
	if newState == _state:
		return
	_state = newState
	if _state == 0:
		_mob.sprite.play_animation("walk")
		_tick = 1
	elif _state == 1:
		_mob.sprite.play_animation("aim")
		_tick = 0.25
	elif _state == 2:
		_mob.sprite.play_animation("shoot")
		_mob.attack.fire(lastTarPos)
		_tick = 0.15
	elif _state == 3:
		_mob.sprite.play_animation("aim")
		_tick = 0.25

func custom_tick(_delta:float, _targetInfo:Dictionary) -> void:
	_tick -= _delta
	if _state == 0:
		_mob.motor.set_target(_targetInfo.position)
		_mob.motor.move_hunt(_delta)
		if _tick <= 0:
			change_state(1)
	elif _state == 1:
		_mob.motor.move_idle(_delta)
		lastTarPos = _targetInfo.position
		_mob.face_target_flat(lastTarPos)
		if _tick <= 0:
			change_state(2)
	elif _state == 2:
		_mob.motor.move_idle(_delta)
		_mob.face_target_flat(_targetInfo.position)
		if _tick <= 0:
			change_state(3)
	elif _state == 3:
		_mob.motor.move_idle(_delta)
		if _tick <= 0:
			change_state(4)
	else:
		change_state(0)
	
