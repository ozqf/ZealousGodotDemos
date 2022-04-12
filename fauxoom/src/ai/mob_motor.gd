# Mob movement base class
# subclass sandbox extended by other classes for actual
# use by mobs
extends Spatial
class_name MobMotor

const STATE_IDLE:int = 0
const STATE_HUNT:int = 1
const STATE_PATROL:int = 2
const STATE_LEAP:int = 3

onready var _floorFront:GroundPointSensor = $floor_in_front
onready var _floorBack:GroundPointSensor = $floor_behind
onready var _floorLeft:GroundPointSensor = $floor_left
onready var _floorRight:GroundPointSensor = $floor_right

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
var evadeSpeed:float = 2

# protected
var _agent:NavAgent = null

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
var moveTargetPos:Vector3 = Vector3()
var _targetForward:Vector3 = Vector3()

var _evadeTarget:Spatial = null 
var _evadeTick:float = 0.0

func get_debug_text() -> String:
	var txt:String = "-MOTOR-\nState: " + str(_state) + "\n"
	txt += "target pos: " + str(moveTargetPos) + "\n"
	txt += "Path nodes: " + str(_agent.pathNumNodes) + "\n"
	txt += "Has node target: " + str(_agent.objectiveNode != null) + "\n"
	return txt

func custom_init(body:KinematicBody) -> void:
	_agent = AI.create_nav_agent()
	_body = body
	_mob = _body
	if moveType == MobMoveType.Flying:
		print("Mob motor is flying")

func get_agent() -> NavAgent:
	return _agent

func motor_change_state(state:int) -> void:
	_state = state

func set_stunned(flag:bool) -> void:
	_stunned = flag

func leap() -> void:
	pass

func start_leap(_delta:float, _speed:float) -> void:
	pass

func move_idle(_delta:float, _friction:float = 0.95) -> void:
	pass

func move_leap(_delta:float, _speed:float) -> void:
	pass

func move_hunt(_delta:float) -> void:
	pass

func move_evade(_delta:float) -> void:
	pass




func mob_died() -> void:
	set_stunned(true)
	moveType = MobMoveType.Ground

func set_is_attacking(flag:bool) -> void:
	_isAttacking = flag

func set_move_target(newTarget:Vector3) -> void:
	_hasTarget = true
	moveTargetPos = newTarget
	_state = STATE_HUNT

func set_move_target_forward(targetForward:Vector3) -> void:
	_targetForward = targetForward

func _set_yaw_by_vector3(velocity:Vector3) -> void:
	velocity.y = 0
	var radians:float = atan2(velocity.x, velocity.z)
	moveYaw = radians - PI
	rotation.y = radians

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
	if _hitInfo.damageType == Interactions.DAMAGE_TYPE_PUNCH:
		strength *= 2
	_velocity += _hitInfo.direction * strength

##################################
# evasion functions
##################################
func _pick_evade_point(_verbose:bool) -> Spatial:
	var r:float = randf()
	var p:Spatial = null
	if _floorLeft.isValid:
		if _floorRight.isValid:
			# pick a direction
			if r > 0.5:
				p = _floorLeft
			else:
				p = _floorRight
		else:
			# only one option!
			p = _floorLeft
	else:
		p = _floorRight
	if p != null:
		if _verbose:
			print("Mob evade to " + p.name)
		_evadeTick = rand_range(1.5, 4)
		return p
	return null

# returns false if no evade target is available
func _tick_evade_status(_delta:float) -> bool:
	_evadeTick -= _delta
	if _evadeTarget != null:
		if !_evadeTarget.isValid:
			_evadeTarget = _pick_evade_point(false)
		elif _evadeTick <= 0.0 && randf() > 0.5:
			_evadeTarget = _pick_evade_point(false)
	else:
		_evadeTarget = _pick_evade_point(false)
		if _evadeTarget == null:
			# we can't move :(
			print(name + " has no evade target")
			return false
	return true

func _evade_step(_delta:float) -> void:
	var from:Vector3 = _body.global_transform.origin
	var to:Vector3 = _evadeTarget.global_transform.origin
	# make sure move is flat!
	to.y = from.y
	var toward:Vector3 = to - from
	toward = toward.normalized()
	_body.move_and_slide(toward * 4)

	# face move (attack) target
	var towardTarget:Vector3 = moveTargetPos - from
	from.y = moveTargetPos.y
	_set_yaw_by_vector3(towardTarget.normalized())
