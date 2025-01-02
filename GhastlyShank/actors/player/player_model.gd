extends Node3D
class_name PlayerModel

@onready var _animator:AnimationPlayer = $AnimationPlayer
#@onready var _body:Node3D = $body

var _idleAnim:String = "_combat_idle"

func set_idle_to_agile() -> void:
	_idleAnim = "_agile_idle"

func set_idle_to_combat() -> void:
	_idleAnim = "_combat_idle"

func play_idle() -> void:
	_animator.play(_idleAnim)

func begin_thrust() -> void:
	_animator.play("thrust_1")
	_animator.queue(_idleAnim)
	pass

func begin_horizontal_swing() -> void:
	#_animator.play("swing_horizontal_1")
	_animator.play("swing_1")
	_animator.queue(_idleAnim)

func begin_uppercut() -> void:
	_animator.play("upper_cut")
	_animator.queue(_idleAnim)

func set_look_yaw(yawRadians:float) -> void:
	var radians:Vector3 = self.rotation
	radians.y = yawRadians
	self.rotation = radians

func is_performing_move() -> bool:
	var anim:String = _animator.current_animation
	if anim == "_agile_idle":
		return false
	if anim == "_combat_idle":
		return false
	return anim != ""
