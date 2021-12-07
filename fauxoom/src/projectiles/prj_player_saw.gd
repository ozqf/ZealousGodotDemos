extends Spatial
class_name SawBlade

enum State { Idle, Thrown, Stuck, Recall }

var _state = State.Idle
var _currentSpeed:float = 25
var _emptyArray = []

func _ready() -> void:
	visible = false

func launch(originT:Transform) -> void:
	visible = true
	global_transform = originT
	_state = State.Thrown
	print("Saw - launch!")

func off() -> void:
	_state = State.Idle
	visible = false

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

func start_recall() -> void:
	_state = State.Recall

# returns 1 if parent can reset to idle state
func read_input(_weaponInput:WeaponInput) -> int:
	var result:int = 0
	if (_state == State.Thrown || _state == State.Stuck) && (_weaponInput.secondaryOn && !_weaponInput.secondaryOnPrev):
		_state = State.Idle
		print("Saw - recall!")
		start_recall()
		result = 0
	if _state == State.Idle:
		result = 1
	return result

func _physics_process(_delta):
	if _state == State.Thrown:
		_move_as_ray(_delta)
	elif _state == State.Stuck:
		pass
	elif _state == State.Recall:
		print("...Recall...")
		var targetDict:Dictionary = AI.get_player_target()
		if targetDict.id == 0:
			off()
			return
		var pos:Vector3 = global_transform.origin
		var tar:Vector3 = targetDict.position
		var dist:float = pos.distance_to(tar)
		if dist <= 2.0:
			off()
			return
		global_transform.origin = pos.linear_interpolate(tar, 0.25)
	else:
		pass
