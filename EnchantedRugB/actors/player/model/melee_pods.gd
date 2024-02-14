extends Node3D
class_name MeleePods

const AnimIdle:String = "idle"
const AnimStowed:String = "stowed"
const AnimJabRight:String = "jab_r"
const AnimJabLeft:String = "jab_l_2"

const AnimChargePunchRight:String = "charge_punch_r"
const AnimChargePunchRightRelease:String = "charge_punch_r_release"

const AnimHorizontalSmash:String = "horizontal_smash"
const AnimCartwheel:String = "cartwheel"

const AnimDoublePunchLaunch:String = "double_punch_launch"

const AnimParried:String = "parried"

####################################
# Animates melee moves.
# the 'pods' in this scene are just position targets
####################################

@onready var _animator:AnimationPlayer = $AnimationPlayer
@onready var _rightPod:Node3D = $right
@onready var _leftPod:Node3D = $left

@onready var _rightGizmo:Node3D = $right/MeshInstance3D
@onready var _leftGizmo:Node3D = $left/MeshInstance3D

enum MeleeState { Idle, Swinging, EnterCharge, Charging }
var _state:MeleeState = MeleeState.Idle

var _currentMoveName:String = ""
var _lastMoveName:String = ""
var _lastReceivedYaw:float = 0.0
var _lastStyleAnim:String = ""

var _moves:Dictionary = {}

var _sequenceCount:int = 0

func _ready():
	_rightGizmo.visible = false
	_leftGizmo.visible = false
	_animator.connect("animation_started", _on_anim_started)
	_animator.connect("animation_finished", _on_anim_finished)
	_animator.connect("animation_changed", _on_anim_changed)
	
	_moves[AnimJabRight] = {
		name = AnimJabRight,
		duration = 0.15,
		damage = 20.0,
		flags = 0
	}
	_moves[AnimJabLeft] = {
		name = AnimJabLeft,
		duration = 0.15,
		damage = 20.0,
		flags = 0
	}
	_moves[AnimChargePunchRightRelease] = {
		name = AnimChargePunchRightRelease,
		duration = 0.1,
		damage = 200,
		flags = 0
	}
	_moves[AnimCartwheel] = {
		name = AnimCartwheel,
		duration = 1.0,
		damage = 20,
		flags = 0
	}
	_moves[AnimHorizontalSmash] = {
		name = AnimHorizontalSmash,
		duration = 1.5,
		damage = 20,
		flags = HitInfo.FLAG_VERTICAL_LAUNCHER
	}
	_moves[AnimParried] = {
		name = AnimCartwheel,
		duration = 2.0,
		damage = 0,
		flags = 0
	}
	_moves[AnimDoublePunchLaunch] = {
		name = AnimDoublePunchLaunch,
		duration = 2.0,
		damage = 50,
		flags = HitInfo.FLAG_HORIZONTAL_LAUNCHER
	}

func attach_animation_key_callback(callable:Callable) -> void:
	_animator.connect("anim_key_event", callable)
	pass

func get_right_fist() -> Node3D:
	return _rightPod

func get_left_fist() -> Node3D:
	return _leftPod

func is_attacking() -> bool:
	return _state != MeleeState.Idle
	#return _currentMoveName != ""

func get_move_data(moveName:String) -> Dictionary:
	if _moves.has(moveName):
		return _moves[moveName]
	return {}

func update_rotation(_input:PlayerInput) -> void:
	#_input.yaw
	var degrees:float = _input.yaw
	_lastReceivedYaw = degrees
	if is_attacking():
		return
	ZqfUtils.look_at_safe(self, _input.aimPoint)
	self.look_at(_input.aimPoint, Vector3.UP)
	#self.rotation_degrees = Vector3(0, degrees, 0)
	pass

############################################################
# animation callbacks
############################################################
func _on_anim_started(_animName:String) -> void:
	pass

func _on_anim_finished(_animName:String) -> void:
	_lastStyleAnim = ""
	if _currentMoveName == _animName:
		_currentMoveName = ""
	match _state:
		MeleeState.EnterCharge:
			_state = MeleeState.Charging
		MeleeState.Charging:
			pass
		_:
			_begin_idle()

func _on_anim_changed(_oldName:String, _newName:String) -> void:
	pass

############################################################
# state
############################################################
func begin_parry() -> void:
	self._begin_swing(AnimParried, false, true)

func _begin_idle() -> void:
	_state = MeleeState.Idle
	_animator.play(AnimIdle)

func _begin_swing(forcedAnim:String = "", applyNewYaw:bool = true, forceStart:bool = false) -> bool:
	if !forceStart && is_attacking():
		return false
	var newMove:String = AnimJabRight
	if _lastMoveName == newMove:
		newMove = AnimJabLeft
	
	if forcedAnim != "":
		newMove = forcedAnim
	
	var moveData:Dictionary = get_move_data(newMove)
	if moveData.is_empty():
		print("Could not find melee move " + newMove)
		return false
	_sequenceCount += 1
	_state = MeleeState.Swinging
	#if applyNewYaw:
	#	self.rotation_degrees = Vector3(0, _lastReceivedYaw, 0)
	_currentMoveName = newMove
	_lastMoveName = _currentMoveName
	_animator.play(_currentMoveName)
	var grp:String = Game.GROUP_PLAYER_INTERNAL
	var fn:String = Game.PLAYER_INTERNAL_FN_MELEE_ATTACK_STARTED
	get_tree().call_group(grp, fn, moveData, _sequenceCount)
	return true

func _begin_charging_attack(_animName:String) -> bool:
	_state = MeleeState.EnterCharge
	_animator.play(_animName)
	return true

func _try_style(_input:PlayerInput) -> bool:
	if _currentMoveName == "":
		if _lastStyleAnim == "":
			if _input.inputDir.z < 0:
				_lastStyleAnim = "style"
				_animator.play(_lastStyleAnim)
				#print("input z " + str(_input.inputDir.z))
			elif _input.inputDir.z > 0:
				_lastStyleAnim = "style_line_in_the_sand"
				_animator.play(_lastStyleAnim)
				#print("input z " + str(_input.inputDir.z))
		_state = MeleeState.Swinging
		return true
	return false

func read_input(_input:PlayerInput) -> void:
	match _state:
		MeleeState.Idle:
			if _input.attack1:
				self._begin_swing(AnimJabLeft)
				#if _input.inputDir.z < 0:
				#	self._begin_swing(AnimCartwheel)
				#else:
				#	self._begin_swing(AnimJabLeft)
			if _input.attack2:
				if _input.isGrounded:
					# forward
					if _input.inputDir.z < 0:
						self._begin_swing(AnimDoublePunchLaunch)
					# backward
					elif _input.inputDir.z > 0:
						self._begin_swing(AnimHorizontalSmash)
					else:
						self._begin_charging_attack(AnimChargePunchRight)
				else:

					pass
			if _input.style && _input.isGrounded:
				return _try_style(_input)
		MeleeState.Charging:
			if !_input.attack2:
				# release!
				_state = MeleeState.Idle
				self._begin_swing(AnimChargePunchRightRelease, false)
