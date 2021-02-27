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

var _curTarget = null

var _moveTick:float = 0
var _moveYaw:float = 0

var _thinkTick:float = 0

var _stunAccumulator:int = 0
var _stunDamageMax:int = 20

var _health:int = 100
var _dead:bool = false

func _ready() -> void:
	print("Mob base init")

func is_dead() -> bool:
	return (_state == MobState.Dead || _state == MobState.Dying)

func _calc_self_move(_delta:float) -> Vector3:
	# look_at(_curTarget.global_transform.origin, Vector3.UP)
	if _moveTick <= 0:
		# decide on next move
		_moveTick = 1
		var selfPos:Vector3 = global_transform.origin
		var tarPos:Vector3 = _curTarget.global_transform.origin
		var dist:float = ZqfUtils.flat_distance_between(selfPos, tarPos)
		if dist > 3:
			_moveYaw = ZqfUtils.yaw_between(selfPos, tarPos)
			var quarter:float = deg2rad(90)
			_moveYaw -= quarter
			_moveYaw += rand_range(0, quarter * 2.0)
	else:
		_moveTick -= _delta
	
	rotation.y = _moveYaw
	var move:Vector3 = Vector3()
	move.x = -sin(_moveYaw)
	move.z = -cos(_moveYaw)
	return move * MOVE_SPEED

func move(_delta:float) -> void:
	var move:Vector3 = _calc_self_move(_delta)
	var _result = self.move_and_slide(move)

func _process(_delta:float) -> void:
	if _state == MobState.Idle:
		pass
	
	var wasNull:bool = _curTarget == null
	_curTarget = game.mob_check_target(_curTarget)
	if _curTarget && wasNull:
		print("Mob got target!")
	elif _curTarget == null && !wasNull:
		print("Mob lost target!")
	
	if _curTarget != null:
		move(_delta)

func hit(_hitInfo:HitInfo) -> void:
	if is_dead():
		return
	_health -= _hitInfo.damage
	if _health <= 0:
		_state = MobState.Dying
		emit_signal("on_mob_died", self)
		queue_free()
