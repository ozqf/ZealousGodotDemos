extends Spatial
class_name SawBlade

enum State { Idle, Thrown, Stuck, Recall }

const GUIDED_SPEED:float = 30.0
const UNGUIDED_SPEED:float = 50.0

onready var _display:Spatial = $display

var _state = State.Idle
var _currentSpeed:float = 25
var _emptyArray = []
var _guided:bool = false
var _hitInfo:HitInfo = null
var _revs:float = 0
var _rotDegrees:float = 0

func _ready() -> void:
	visible = false
	_hitInfo = Game.new_hit_info()
	_hitInfo.damage = 15
	_hitInfo.damageType = Interactions.DAMAGE_TYPE_SAW

func launch(originT:Transform, revs:float) -> void:
	visible = true
	_revs = revs
	global_transform = originT
	_state = State.Thrown
	# print("Saw - launch!")

func off() -> void:
	_state = State.Idle
	visible = false

func _move_as_ray(_delta:float, speed:float) -> void:
	var t:Transform = global_transform
	var space = get_world().direct_space_state
	var origin:Vector3 = t.origin
	var dir:Vector3 = -t.basis.z
	# move ray origin back slightly or tunneling can occur.
	origin -= (dir * 0.1)
	var velocity:Vector3 = (dir * speed) * _delta
	var dest:Vector3 = origin + velocity

	var mask:int = -1
	# interactives are 'areas' so also need to hit these
	var result = space.intersect_ray(origin, dest, _emptyArray, mask, true, true)
	var move:bool = true
	if result:
		_hitInfo.direction = dir

		var _inflicted:int = Interactions.hitscan_hit(_hitInfo, result)
		if _inflicted >= 0:
			print("Hit entity")
			start_recall()
			return

		var body:CollisionObject = result.collider
		# check vs interactor
		if (body.collision_layer & Interactions.INTERACTIVE) != 0:
			print("Hit interactive body")
			Interactions.use_collider(body)
			_state = State.Stuck
			move = false
			# print("Saw - stuck!")
			global_transform.origin = result.position
			return

		# check vs world
		if (body.collision_layer & 1) != 0:
			print("Hit world")
			_state = State.Stuck
			move = false
			# print("Saw - stuck!")
			global_transform.origin = result.position
			return
	if move:
		global_transform.origin = dest

func start_recall() -> void:
	_state = State.Recall

func turn_toward_point(pos:Vector3) -> void:
	var towardPoint:Transform = global_transform.looking_at(pos, Vector3.UP)
	var result:Transform = transform.interpolate_with(towardPoint, 0.8)
	set_transform(result)

# returns 1 if parent can reset to idle state
func read_input(_weaponInput:WeaponInput) -> int:
	var result:int = 0
	if _state == State.Thrown:
		_guided = _weaponInput.secondaryOn
	if (_state == State.Thrown || _state == State.Stuck) && (_weaponInput.secondaryOn && !_weaponInput.secondaryOnPrev):
		_state = State.Idle
		# print("Saw - recall!")
		start_recall()
		result = 0
	if _state == State.Idle:
		result = 1
	return result

func spin_display(_delta:float) -> void:
	_rotDegrees -= (360 * 4) * _delta
	_display.rotation_degrees = Vector3(_rotDegrees, 0, 0)

func _physics_process(_delta):
	var targetDict:Dictionary = AI.get_player_target()
	if targetDict.id == 0:
		off()
		return
	if _state == State.Thrown:
		spin_display(_delta)
		if _guided:
			turn_toward_point(targetDict.aimPos)
			_move_as_ray(_delta, GUIDED_SPEED)
		else:
			_move_as_ray(_delta, UNGUIDED_SPEED)
	elif _state == State.Stuck:
		spin_display(_delta)
	elif _state == State.Recall:
#		print("...Recall tick...")
		var pos:Vector3 = global_transform.origin
		var tar:Vector3 = targetDict.position
		var dist:float = pos.distance_to(tar)
		if dist <= 2.0:
			off()
			return
		global_transform.origin = pos.linear_interpolate(tar, 0.25)
	else:
		pass
