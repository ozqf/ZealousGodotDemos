extends Node3D
class_name MeleePods

const AnimIdle:String = "idle"
const AnimStowed:String = "stowed"
const AnimJabRight:String = "jab_r"
const AnimJabLeft:String = "jab_l"

####################################
# Animates melee moves.
# the 'pods' in this scene are just position targets
####################################

@onready var _animator:AnimationPlayer = $AnimationPlayer
@onready var _rightPod:Node3D = $right
@onready var _leftPod:Node3D = $left

@onready var _rightGizmo:Node3D = $right/MeshInstance3D
@onready var _leftGizmo:Node3D = $left/MeshInstance3D

var _currentMoveName:String = ""
var _lastMoveName:String = ""
var _lastReceivedYaw:float = 0.0

var _moves:Dictionary = {}

func _ready():
	_rightGizmo.visible = false
	_leftGizmo.visible = false
	_animator.connect("animation_started", _on_anim_started)
	_animator.connect("animation_finished", _on_anim_finished)
	_animator.connect("animation_changed", _on_anim_changed)
	_moves[AnimJabRight] = {
		name = AnimJabRight,
		duration = 0.15,
		damage = 50.0
	}
	_moves[AnimJabLeft] = {
		name = AnimJabLeft,
		duration = 0.15,
		damage = 50.0
	}

func _on_anim_started(_animName:String) -> void:
	pass

func _on_anim_finished(_animName:String) -> void:
	if _currentMoveName == _animName:
		_currentMoveName = ""
	pass

func _on_anim_changed(_oldName:String, _newName:String) -> void:
	pass

func get_right_fist() -> Node3D:
	return _rightPod

func get_left_fist() -> Node3D:
	return _leftPod

func is_attacking() -> bool:
	return _currentMoveName != ""

func get_move_data(moveName:String) -> Dictionary:
	if _moves.has(moveName):
		return _moves[moveName]
	return {}

func update_yaw(_degrees:float) -> void:
	_lastReceivedYaw = _degrees
	if is_attacking():
		return
	self.rotation_degrees = Vector3(0, _degrees, 0)
	pass

func jab() -> bool:
	if is_attacking():
		return false
	var newMove:String = AnimJabRight
	if _lastMoveName == newMove:
		newMove = AnimJabLeft
	
	self.rotation_degrees = Vector3(0, _lastReceivedYaw, 0)
	_currentMoveName = newMove
	_lastMoveName = _currentMoveName
	_animator.play(_currentMoveName)
	var grp:String = Game.GROUP_PLAYER_INTERNAL
	var fn:String = Game.PLAYER_INTERNAL_FN_MELEE_ATTACK_STARTED
	get_tree().call_group(grp, fn, get_move_data(_currentMoveName))
	return true
