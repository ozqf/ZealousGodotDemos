extends RigidBody

const Enums = preload("res://src/enums.gd")

# const ANIMATION_HEALTH_MINOR:String = "health_minor"
# const ANIMATION_ADRENALINE_MINOR:String = "adrenaline_minor"
# const ANIMATION_BONUS_MINOR:String = "bonus_minor"

const ANIMATION_HEALTH_MINOR:String = "blue_capsule"
const ANIMATION_ADRENALINE_MINOR:String = "green_capsule"
const ANIMATION_BONUS_MINOR:String = "bonus_minor"


@export var time:float = 4
@export var remove_parent:bool = false

@onready var _sprite = $Sprite3D
@onready var _toward:Node3D = $toward
@onready var _light:OmniLight = $OmniLight

enum State { Idle, Gather, Dead }

var _state = State.Idle
var _tick:float = 0
var _type:int = Enums.QuickDropType.Rage

var _lifeTime:float = 0.0
var _gatheringTime:float = 0.0

var _gatherRange:float = 6
var _gatherSpeed:float = 1
var _gatherSpeedMax:float = 50
var _gatherSpeedAccel:float = 30
var _turnWeight:float = 0.1
var _kinematicVelocity:Vector3 = Vector3()

func _ready() -> void:
	#if randf() > 0.5:
	#	_sprite.animation = "blue_capsule"
	pass

func _remove() -> void:
	_state = State.Dead
	self.queue_free()

func launch_rage_drop(pos:Vector3, dropType:int, throwYawDegrees:float, autoGather:bool) -> void:
	global_transform.origin = pos
	var velocity:Vector3 = Vector3()
	if throwYawDegrees < 0.0:
		velocity.x += randf_range(-5, 5)
		velocity.z += randf_range(-5, 5)
	else:
		#print("Throw rage yaw " + str(throwYawDegrees))
		throwYawDegrees += randf_range(-45, 45)
		velocity = ZqfUtils.yaw_to_flat_vector3(throwYawDegrees)
		velocity *= randf_range(3, 6)
	velocity.y += randf_range(5, 10)
	linear_velocity = velocity
	
	# converts excess health to 'bonus' items.
	# not sure what I want to do with them though
	#if dropType == Enums.QuickDropType.Health:
	#	var plyr:Dictionary = AI.get_player_target()
	#	if plyr.id != 0 && plyr.health >= 100:
	#		print("Convert to minor bonus")
	#		dropType = Enums.QuickDropType.Bonus
	#	else:
	#		print("Cannot convert to minor bonus")
	
	_type = dropType
	if _type == Enums.QuickDropType.Rage:
		_sprite.animation = ANIMATION_ADRENALINE_MINOR
		time = 4
		_light.light_color = Color.GREEN
	elif _type == Enums.QuickDropType.Bonus:
		_sprite.animation = ANIMATION_BONUS_MINOR
		time = 8
		_light.light_color = Color.yellow
	else:
		_sprite.animation = ANIMATION_HEALTH_MINOR
		time = 8
		_light.light_color = Color.blue
	
	if autoGather && !_give_check():
		_start_gather()
		# skip the short delay before gather
		_lifeTime = 2.0

func _give_check() -> bool:
	if _type == Enums.QuickDropType.Rage:
		return AI.give_to_player("rage", 2) == 0
	if _type == Enums.QuickDropType.Health:
		return AI.give_to_player("health_bonus", 4) == 0
	else:
		return AI.give_to_player("bonus", 1) == 0

func _start_gather() -> void:
	_state = State.Gather
	_sprite.modulate = Color.white

func _start_kinematic_move() -> void:
	var movePos:Vector3
	#_kinematicVelocity = linear_velocity
	#_gatherSpeed = _kinematicVelocity.length()
	var curSpeed:float = linear_velocity.length()
	_gatherSpeed = curSpeed
	if curSpeed > 0.1:
		_kinematicVelocity = linear_velocity
		movePos = global_transform.origin + linear_velocity
	else:
		movePos = global_transform.origin + Vector3.UP
	# var moveDir:Vector3 = global_transform.origin + linear_velocity
	ZqfUtils.look_at_safe(_toward, movePos)
	# if moveDir != Vector3.UP:
	# 	look_at(selfPos + linear_velocity, Vector3.UP)
	# ZqfUtils.look_at_safe(self, movePos)
	var speed:float = linear_velocity.length()
	# print("rage spawned at speed: " + str(speed))
	mode = RigidBody.MODE_KINEMATIC


func broadcast_pickup() -> void:
	var grp = Groups.PLAYER_GROUP_NAME
	var fn = Groups.PLAYER_FN_PICKUP
	var description = ""
	get_tree().call_group(grp, fn, description)


func _process(_delta:float):
	_lifeTime += _delta
	if _state == State.Idle:
		_tick += _delta
		if _tick >= time:
			_remove()
			return
		var percent:float = _tick / time
		percent = 1.0 - percent
		_sprite.modulate = Color(1 * percent, 1 * percent, 1 * percent, 1)
		var dict:Dictionary = AI.get_player_target()
		if dict.id == 0:
			return
		var targetPos:Vector3 = dict.position
		var selfPos:Vector3 = self.global_transform.origin
		var dist:float = selfPos.distance_to(targetPos)
		var noAttackWeight:float = dict.noAttackTime / 4.0
		if noAttackWeight > 1:
			noAttackWeight = 1
		var bonusRange:float = 4.0 * noAttackWeight
		if dist > (_gatherRange + bonusRange):
			return
		# if AI.give_to_player("rage", 5) == 0:
		# 	return
		if _give_check():
			return
		_start_gather()
	elif _state == State.Gather:
		_gatheringTime += _delta
		if _gatheringTime > 10.0:
			_remove()
			return
		var isKinematic:bool = mode == RigidBody.MODE_KINEMATIC
		if !isKinematic:
			if _lifeTime > 0.5: #1.2:
				_start_kinematic_move()
			else:
				return
		#if _lifeTime > 1.5 && !isKinematic:
		#	_start_kinematic_move()
		var dict:Dictionary = AI.get_player_target()
		if dict.id == 0:
			_remove()
			return

		# k, kinematic move
		var targetPos:Vector3 = dict.position - Vector3(0, 0.6, 0)
		var selfPos:Vector3 = self.global_transform.origin
		var dist:float = selfPos.distance_to(targetPos)
		if dist < 0.2:
			broadcast_pickup()
			_remove()
			return
		
		# accelerate...
		_gatherSpeed += _gatherSpeedAccel * _delta
		if _gatherSpeed > _gatherSpeedMax:
			_gatherSpeed = _gatherSpeedMax
		
		_gatherSpeed = 2
		var t:Transform3D = global_transform
		
		# terrible janky orbit
		
		#var toward:Vector3 = (targetPos - selfPos).normalized()
		#var forward:Vector3 = _kinematicVelocity.normalized()
		#forward += (toward * _delta)
		#forward = forward.normalized()
		#_kinematicVelocity = forward * _gatherSpeed
		#global_transform.origin += (_kinematicVelocity * _delta)


		# boring move directly to player
		# var toward:Vector3 = (targetPos - selfPos).normalized()
		# var lookPos:Vector3 = t.origin + toward
		# _kinematicVelocity += (toward)
		# _kinematicVelocity += (toward * _delta)
		# _kinematicVelocity = _kinematicVelocity.normalized() * _gatherSpeed
		# global_transform.origin += (_kinematicVelocity * _delta)

		# ZqfUtils.turn_towards_point(_toward, targetPos, _turnWeight)
		# var forward:Vector3 = -_toward.global_transform.basis.z
		# var forward:Vector3 = (targetPos - selfPos).normalized()
		# selfPos += (forward * _gatherSpeed) * _delta
		# global_transform.origin = selfPos
		
		var toward:Vector3 = (targetPos - selfPos).normalized()
		var newPos:Vector3 = t.origin + (toward * (15.0 * _delta))
		global_transform.origin = newPos

		# _turnWeight += _delta * 1.0
		# if _turnWeight > 1:
		# 	_turnWeight = 1
	else:
		pass
