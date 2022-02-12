extends RigidBody

const Enums = preload("res://src/enums.gd")

const HEALTH_MINOR:String = "health_minor"
const ADRENALINE_MINOR:String = "adrenaline_minor"
const BONUS_MINOR:String = "bonus_minor"

export var time:float = 4
export var remove_parent:bool = false

onready var _sprite = $Sprite3D

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
var _turnWeight:float = 0.025
var _kinematicVelocity:Vector3 = Vector3()

func _ready() -> void:
	#if randf() > 0.5:
	#	_sprite.animation = "blue_capsule"
	pass

func _remove() -> void:
	_state = State.Dead
	self.queue_free()

func launch(pos:Vector3, dropType:int) -> void:
	global_transform.origin = pos
	var velocity:Vector3 = Vector3()
	velocity.x += rand_range(-5, 5)
	velocity.y += rand_range(5, 10)
	velocity.z += rand_range(-5, 5)
	linear_velocity = velocity
	
	if dropType == Enums.QuickDropType.Health:
		var plyr:Dictionary = AI.get_player_target()
		if plyr.id != 0 && plyr.health >= 100:
			print("Convert to minor bonus")
			dropType = Enums.QuickDropType.Bonus
		else:
			print("Cannot convert to minor bonus")
	
	_type = dropType
	if _type == Enums.QuickDropType.Rage:
		_sprite.animation = ADRENALINE_MINOR
		time = 4
	elif _type == Enums.QuickDropType.Bonus:
		_sprite.animation = BONUS_MINOR
		time = 8
	else:
		_sprite.animation = HEALTH_MINOR
		time = 8

func _give_check() -> bool:
	if _type == Enums.QuickDropType.Rage:
		return AI.give_to_player("rage", 2) == 0
	if _type == Enums.QuickDropType.Health:
		return AI.give_to_player("health", 4) == 0
	else:
		return AI.give_to_player("bonus", 1) == 0

func _start_gather() -> void:
	_state = State.Gather
	_sprite.modulate = Color.white

func _start_kinematic_move() -> void:
	# var movePos:Vector3
	_kinematicVelocity = linear_velocity
	_gatherSpeed = _kinematicVelocity.length()
	# if linear_velocity.length() > 0.1:
		#_kinematicVelocity = linear_velocity
	# 	movePos = global_transform.origin + linear_velocity
	# else:
	# 	movePos = global_transform.origin + Vector3.UP
	#var moveDir:Vector3 = global_transform.origin + linear_velocity
	#if moveDir != Vector3.UP:
	#	look_at(selfPos + linear_velocity, Vector3.UP)
	# ZqfUtils.look_at_safe(self, movePos)
	# var speed:float = linear_velocity.length()
	# print("rage spawned at speed: " + str(speed))
	mode = RigidBody.MODE_KINEMATIC

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
			if _lifeTime > 0.6:
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
		var targetPos:Vector3 = dict.position
		var selfPos:Vector3 = self.global_transform.origin
		var dist:float = selfPos.distance_to(targetPos)
		if dist < 0.2:
			_remove()
			return
		
		# accelerate...
		_gatherSpeed += _gatherSpeedAccel * _delta
		if _gatherSpeed > _gatherSpeedMax:
			_gatherSpeed = _gatherSpeedMax
		
		var t:Transform = global_transform
		
		# terrible janky orbit
		
		#var toward:Vector3 = (targetPos - selfPos).normalized()
		#var forward:Vector3 = _kinematicVelocity.normalized()
		#forward += (toward * _delta)
		#forward = forward.normalized()
		#_kinematicVelocity = forward * _gatherSpeed
		#global_transform.origin += (_kinematicVelocity * _delta)


		# boring move directly to player
		var toward:Vector3 = (targetPos - selfPos).normalized() * _gatherSpeed
		_kinematicVelocity += (toward)
		_kinematicVelocity += (toward * _delta)
		_kinematicVelocity = _kinematicVelocity.normalized() * _gatherSpeed
		global_transform.origin += (_kinematicVelocity * _delta)
		ZqfUtils.turn_towards_point(self, targetPos, _turnWeight)
		var forward:Vector3 = -t.basis.z
		# var forward:Vector3 = (targetPos - selfPos).normalized()
		selfPos += (forward * _gatherSpeed) * _delta
		global_transform.origin = selfPos

		_turnWeight += _delta * 1.0
		if _turnWeight > 1:
			_turnWeight = 1
	else:
		pass
