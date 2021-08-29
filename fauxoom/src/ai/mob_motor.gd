extends Spatial
class_name MobMotor

const STATE_IDLE:int = 0
const STATE_HUNT:int = 1
const STATE_PATROL:int = 2
const STATE_LEAP:int = 3

var _floorInFront:RayCast

enum MobMoveType {
	Ground,
	Flying
}

enum MobMoveStyle {
	CloseStraight,
	CloseEvasive,
	KeepDistance
}

# export
export(MobMoveType) var moveType = MobMoveType.Ground
export(MobMoveStyle) var moveStyle = MobMoveStyle.CloseStraight
export var inactiveWhenAttacking:bool = false
export var evadeDegrees:float = 65
export var panicEvadeDegreesMin:float = 100
export var panicEvadeDegreesMax:float = 180

# public
var moveYaw:float = 0.0
var speed:float = 4.5

# protected

# components
var _body:KinematicBody = null
var _mob = null

# status
var _velocity:Vector3 = Vector3()
var _state:int = STATE_IDLE
var _stunned:bool = false
var _isAttacking:bool = false
var _hasTarget:bool = false

# targetting/objective
var _target:Vector3 = Vector3()
var _targetForward:Vector3 = Vector3()

func custom_init(body:KinematicBody) -> void:
	_body = body
	_mob = _body
	_floorInFront = $floor_in_front
	if moveType == MobMoveType.Flying:
		print("Mob motor is flying")

func motor_change_state(state:int) -> void:
	_state = state

func set_stunned(flag:bool) -> void:
	_stunned = flag

func leap() -> void:
	pass

func move_idle(_delta:float, _friction:float = 0.95) -> void:
	pass

func move_leap(_delta:float, _speed:float) -> void:
	pass

func move_hunt(_delta:float) -> void:
	pass

func mob_died() -> void:
	set_stunned(true)
	moveType = MobMoveType.Ground

func set_is_attacking(flag:bool) -> void:
	_isAttacking = flag

func set_move_target(target:Vector3) -> void:
	_hasTarget = true
	_target = target
	_state = STATE_HUNT

func set_move_target_forward(targetForward:Vector3) -> void:
	_targetForward = targetForward

func _set_move_yaw(radians:float) -> void:
	moveYaw = radians
	rotation.y = moveYaw

func clear_target() -> void:
	_hasTarget = false
	motor_change_state(STATE_IDLE)

func damage_hit(_hitInfo:HitInfo) -> void:
	var strength:float = 1
	if _stunned:
		strength = 1.5
	_velocity += _hitInfo.direction * strength

