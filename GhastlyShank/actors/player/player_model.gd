extends Node3D
class_name PlayerModel

const BLINK_TIME:float = 0.05

@onready var _animator:AnimationPlayer = $AnimationPlayer
@onready var _body:Node3D = $body

var _idleAnim:String = "_combat_idle"
var _blinkTick:float = 0.0
var _isBlinking:bool = false

func set_blinking(flag:bool) -> void:
	if !_isBlinking && flag:
		_blinkTick = BLINK_TIME
	_isBlinking = flag
	if !_isBlinking:
		_body.visible = true

func _process(_delta:float) -> void:
	if _isBlinking:
		_blinkTick -= _delta
		if _blinkTick <= 0.0:
			_blinkTick = BLINK_TIME
			_body.visible = !_body.visible

func set_idle_to_agile() -> void:
	_idleAnim = "_agile_idle"

func set_idle_to_combat() -> void:
	_idleAnim = "_combat_idle"

func play_idle() -> void:
	_animator.play(_idleAnim)

func begin_flinch() -> void:
	_animator.play("combat_flinch")
	_animator.play(_idleAnim)

func begin_parry() -> void:
	_animator.play("combat_parry")
	_animator.play(_idleAnim)

func begin_agile_whirlwind() -> void:
	_animator.play("agile_whirlwind")
	_animator.queue(_idleAnim)

func begin_thrust() -> void:
	_animator.play("thrust_1")
	_animator.queue(_idleAnim)

func begin_horizontal_swing() -> void:
	_animator.play("swing_quick_1")
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
