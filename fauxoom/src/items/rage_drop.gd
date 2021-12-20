extends RigidBody

const Enums = preload("res://src/enums.gd")

export var time:float = 4
export var remove_parent:bool = false

onready var _sprite = $Sprite3D

enum State { Idle, Gather, Dead }

var _state = State.Idle
var _tick:float = 0
var _type:int = Enums.QuickDropType.Rage

var _gatherRange:float = 5
var _gatherSpeed:float = 1
var _gatherSpeedMax:float = 15
var _gatherSpeedAccel:float = 30

func _ready() -> void:
	if randf() > 0.5:
		_sprite.animation = "blue_capsule"
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
	
	_type = dropType
	if _type == Enums.QuickDropType.Rage:
		_sprite.animation = "green_capsule"
	else:
		_sprite.animation = "blue_capsule"

func _give_check() -> bool:
	if _type == Enums.QuickDropType.Health:
		return AI.give_to_player("health", 5) == 0
	else:
		return AI.give_to_player("rage", 5) == 0

func _process(_delta:float):
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
		if dist > _gatherRange:
			return
		# if AI.give_to_player("rage", 5) == 0:
		# 	return
		if _give_check():
			return
		_state = State.Gather
		look_at(selfPos + linear_velocity, Vector3.UP)
		mode = RigidBody.MODE_KINEMATIC
		_sprite.modulate = Color.white
	elif _state == State.Gather:
		var dict:Dictionary = AI.get_player_target()
		if dict.id == 0:
			_remove()
			return
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
		# ...toward player

		# boring move directly to player
		var t:Transform = global_transform
		ZqfUtils.turn_towards_point(self, targetPos, 0.3)
		var forward:Vector3 = -t.basis.z
		# var forward:Vector3 = (targetPos - selfPos).normalized()
		selfPos += (forward * _gatherSpeed) * _delta
		global_transform.origin = selfPos
	else:
		pass
