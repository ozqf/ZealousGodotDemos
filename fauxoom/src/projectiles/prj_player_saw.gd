extends Spatial
class_name SawBlade

enum State { Idle, Thrown, Stuck, Recall }

var _state = State.Idle
var _currentSpeed:float = 25
var _emptyArray = []

var _primaryOnLast:bool = false
var _secondaryOnLast:bool = false

func launch(originT:Transform) -> void:
	global_transform = originT
	_state = State.Thrown
	print("Saw - launch!")

func _move_as_ray(_delta:float) -> void:
	var t:Transform = global_transform
	var space = get_world().direct_space_state
	var origin:Vector3 = t.origin
	var dir:Vector3 = -t.basis.z
	var velocity:Vector3 = (dir * _currentSpeed) * _delta
	var dest:Vector3 = origin + velocity

	var mask:int = -1
	var result = space.intersect_ray(origin, dest, _emptyArray, mask)
	var move:bool = true
	if result:
		var body:CollisionObject = result.collider
		if (body.collision_layer & 1) != 0:
			_state = State.Stuck
			move = false
			print("Saw - stuck!")
			global_transform.origin = result.position
	global_transform.origin = dest

# returns 1 if parent can reset to idle state
func read_input(_weaponInput:WeaponInput) -> int:
	var result:int = 0
	if (_state == State.Thrown || _state == State.Stuck) && _weaponInput.secondaryOn && !_secondaryOnLast:
		_state = State.Idle
		print("Saw - recall!")
		result = 1
	
	# _primaryOnLast = _primaryOn
	# _secondaryOnLast = _secondaryOn
	return result


func _physics_process(_delta):
	if _state == State.Thrown:
		_move_as_ray(_delta)
	elif _state == State.Stuck:
		pass
	elif _state == State.Recall:
		pass
	else:
		pass
