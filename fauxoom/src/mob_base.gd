extends KinematicBody
class_name MobBase

signal on_mob_died(mob)

onready var _sprite:EntitySprite = $body

const MOVE_SPEED:float = 5.0

enum MobState {
	Idle,
	Spawning,
	Hunting,
	Stunned,
	Dying,
	Dead
}

var _state = MobState.Idle

# var _curTarget = null
var _tarId:int = 0
var _targetInfo: Dictionary = { id = 0 }

var _moveTick:float = 0
var _moveYaw:float = 0

var _thinkTick:float = 0

var _stunAccumulator:int = 0
var _stunDamageMax:int = 20

var _health:int = 100
var _dead:bool = false

func _ready() -> void:
	print("Mob base init")
	add_to_group(Groups.GAME_GROUP_NAME)

func game_on_reset() -> void:
	print("Mob saw game reset")
	queue_free()

func is_dead() -> bool:
	return (_state == MobState.Dead || _state == MobState.Dying)

func _calc_self_move(_delta:float) -> Vector3:
	# look_at(_curTarget.global_transform.origin, Vector3.UP)
	if _moveTick <= 0:
		# decide on next move
		_moveTick = 1
		var selfPos:Vector3 = global_transform.origin
		# var tarTrans:Transform = _curTarget.global_transform
		# var tarPos:Vector3 = tarTrans.origin
		var tarPos:Vector3 = _targetInfo.position
		var _tarYaw:float = _targetInfo.yawDegrees
		var dist:float = ZqfUtils.flat_distance_between(selfPos, tarPos)
		if dist > 15:
			_moveYaw = ZqfUtils.yaw_between(selfPos, tarPos)
		elif dist > 3:
			# var tarFacing:float = _calc_target_side(selfPos, tarPos, -tarTrans.basis.z)
			_moveYaw = ZqfUtils.yaw_between(selfPos, tarPos)
			
			# apply evasion from player aim direction
			var leftOfTar:bool = ZqfUtils.is_point_left_of_line3D_flat(tarPos, _targetInfo.forward, selfPos)
			if leftOfTar:
				print("left at " + str(selfPos))
				_moveYaw -= deg2rad(90)
			else:
				print("right at " + str(selfPos))
				_moveYaw += deg2rad(90)
			
			# apply some random evasion - very jittery
#			var quarter:float = deg2rad(90)
#			_moveYaw -= quarter
#			_moveYaw += rand_range(0, quarter * 2.0)
		else:
			_moveYaw = rand_range(0, PI * 2)
	else:
		_moveTick -= _delta
	
	rotation.y = _moveYaw
	var move:Vector3 = Vector3()
	move.x = -sin(_moveYaw)
	move.z = -cos(_moveYaw)
	move *= MOVE_SPEED
	return move
	# return Vector3()

func move(_delta:float) -> void:
	var move:Vector3 = _calc_self_move(_delta)
	var _result = self.move_and_slide(move)

func _process(_delta:float) -> void:
	if _state == MobState.Idle:
		pass
	
	var wasEmpty:bool = (_targetInfo.id == 0)
	_targetInfo = Game.mob_check_target(_targetInfo)
	if _targetInfo.id != 0 && wasEmpty:
		print("Mob got target!")
	elif _targetInfo.id == 0 && !wasEmpty:
		print("Mob lost target!")
	
	if _targetInfo.id != 0:
		move(_delta)
	
	# var wasNull:bool = _curTarget == null
	# _curTarget = Game.mob_check_target(_curTarget)
	# if _curTarget && wasNull:
	# 	print("Mob got target!")
	# elif _curTarget == null && !wasNull:
	# 	print("Mob lost target!")
	
	# if _curTarget != null:
	# 	move(_delta)

func hit(_hitInfo:HitInfo) -> void:
	if is_dead():
		return
	_health -= _hitInfo.damage
	if _health <= 0:
		_state = MobState.Dying
		emit_signal("on_mob_died", self)
		queue_free()
