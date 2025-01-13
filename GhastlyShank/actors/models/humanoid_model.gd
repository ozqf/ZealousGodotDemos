extends Node3D
class_name HumanoidModel

signal on_hurtbox_touched_victim(_model:HumanoidModel, _source:Area3D, _victim:Area3D)

const ANIM_IDLE:String = "_idle"
const ANIM_IDLE_AGILE:String = "_idle_agile"
const ANIM_EVADE_STATIC_1:String = "evade_static_1"
const ANIM_EVADE_STATIC_2:String = "evade_static_2"
const ANIM_JAB:String = "jab"
const ANIM_SPIN_BACK_KICK:String = "spin_back_kick"
const ANIM_UPPERCUT:String = "uppercut"

const ANIM_FLINCH:String = "flinch"
const ANIM_DAZED:String = "dazed"

const BLINK_TIME:float = 0.05

const STANCE_COMBAT:int = 0
const STANCE_AGILE:int = 1

const STATE_NEUTRAL:int = 0
const STATE_PERFORMING_MOVE:int = 1
const STATE_HIT_FLINCHING:int = 2
const STATE_DAZED:int = 3

@onready var _animator:AnimationPlayer = $AnimationPlayer
@onready var _leftHandArea:Area3D = $hitboxes/hand_l/Area3D
@onready var _rightHandArea:Area3D = $hitboxes/hand_r/Area3D
@onready var _leftFootArea:Area3D = $hitboxes/foot_l/Area3D
@onready var _rightFootArea:Area3D = $hitboxes/foot_r/Area3D

var _charBody:CharacterBody3D = null
var _hitbox:Area3D = null

var _state:int = STATE_NEUTRAL
var _stance:int = STANCE_COMBAT

var _idleAnim:String = ANIM_IDLE
var _blinkTick:float = 0.0
var _isBlinking:bool = false
var _isHitting:bool = false
var _hitTick:float = 0.0

func _ready() -> void:
	_leftHandArea.monitoring = false
	_rightHandArea.monitoring = false
	_leftFootArea.monitoring = false
	_rightFootArea.monitoring = false

func attach_character_body(charBody:CharacterBody3D, hitbox:Area3D) -> void:
	_charBody = charBody
	_hitbox = hitbox

func _all_hurtboxes_off() -> void:
	_isHitting = false
	_leftHandArea.monitoring = false
	_rightHandArea.monitoring = false
	_leftFootArea.monitoring = false
	_rightFootArea.monitoring = false

# queued animation has started
func _on_animation_changed(_oldName:String, _newName:String) -> void:
	if _newName == ANIM_IDLE || _newName == ANIM_IDLE_AGILE:
		_all_hurtboxes_off()

# 'play' was called
func _on_current_animation_changed(_anim:String) -> void:
	pass

func begin_move(animName:String) -> void:
	print("Begin move " + animName)
	_animator.play(animName)
	_animator.queue(_idleAnim)

func _start_hit_tick(hitTime:float = 0.1) -> void:
	_hitTick = hitTime
	print("Hit tick " + str(_hitTick))
	_isHitting = true

func set_idle_to_agile() -> void:
	_idleAnim = ANIM_IDLE_AGILE

func set_idle_to_combat() -> void:
	_idleAnim = ANIM_IDLE

func play_idle() -> void:
	_animator.play(_idleAnim)

func _begin_evade_shared() -> void:
	_all_hurtboxes_off()
	_animator.queue(_idleAnim)

func begin_evade_static() -> void:
	if randf() > 0.5:
		_animator.play(ANIM_EVADE_STATIC_1)
	else:
		_animator.play(ANIM_EVADE_STATIC_2)
	_begin_evade_shared()

func begin_evade_left() -> void:
	_animator.play(ANIM_EVADE_STATIC_1)
	_begin_evade_shared()

func  begin_evade_right() -> void:
	_animator.play(ANIM_EVADE_STATIC_2)
	_begin_evade_shared()

func begin_flinch() -> void:
	_animator.play("flinch")

func begin_parried() -> void:
	_animator.play("flinch")

func begin_agile_whirlwind() -> void:
	pass

func begin_thrust() -> void:
	_rightFootArea.monitoring = true
	_start_hit_tick(0.4667)
	_animator.play(ANIM_SPIN_BACK_KICK)
	_animator.queue(_idleAnim)

func begin_sweep(speedWeight:float = 1.0) -> void:
	_start_hit_tick(0.33 * speedWeight)
	_rightFootArea.monitoring = true
	_animator.play("sweep", -1, speedWeight)
	_animator.queue(_idleAnim)

func begin_horizontal_swing() -> void:
	_animator.play(ANIM_JAB)
	_start_hit_tick(0.1)
	_leftHandArea.monitoring = true
	_animator.queue(_idleAnim)

func begin_uppercut() -> void:
	_rightHandArea.monitoring = true
	_start_hit_tick(0.4667)
	_animator.play(ANIM_UPPERCUT)
	_animator.queue(_idleAnim)

func set_blinking(flag:bool) -> void:
	if !_isBlinking && flag:
		_blinkTick = BLINK_TIME
	_isBlinking = flag
	if !_isBlinking:
		self.visible = true

func _check_area_for_hits(hurtBox:Area3D) -> void:
	if !hurtBox.monitoring:
		return
	var areas:Array[Area3D] = hurtBox.get_overlapping_areas()
	var num:int = areas.size()
	for i in range(0, num):
		var victim:Area3D = areas[0]
		on_hurtbox_touched_victim.emit(self, hurtBox, victim)

func _check_for_hits() -> void:
	_check_area_for_hits(_leftHandArea)
	_check_area_for_hits(_rightHandArea)
	_check_area_for_hits(_leftFootArea)
	_check_area_for_hits(_rightFootArea)

func _process(_delta:float) -> void:
	if _isHitting:
		_hitTick -= _delta
		if _hitTick <= 0.0:
			_isHitting = false
			_check_for_hits()
			_all_hurtboxes_off()

	if _isBlinking:
		_blinkTick -= _delta
		if _blinkTick <= 0.0:
			_blinkTick = BLINK_TIME
			self.visible = !self.visible

func set_look_yaw(yawRadians:float) -> void:
	var radians:Vector3 = self.rotation
	radians.y = yawRadians
	radians.y += PI;
	self.rotation = radians

func look_at_flat(_target:Vector3) -> void:
	var pos:Vector3 = self.global_position
	var yaw:float = ZqfUtils.yaw_between(pos, _target)
	set_look_yaw(yaw)

func is_performing_move() -> bool:
	var anim:String = _animator.current_animation
	if anim == ANIM_IDLE:
		return false
	if anim == ANIM_EVADE_STATIC_1 || anim == ANIM_EVADE_STATIC_2:
		return false
	return anim != ""

func custom_physics_process(_delta: float, _pushDir:Vector3, _desiredYaw:float) -> void:
	if is_performing_move():
		return
	
	var verticalSpeed:float = _charBody.velocity.y
	_charBody.velocity = _pushDir * 3.0
	if _charBody.is_on_floor() && _pushDir.y > 0: # jump
		_charBody.velocity.y = 5.0
	else: # fall
		_charBody.velocity.y = verticalSpeed + (-20.0 * _delta)
	_charBody.move_and_slide()
	
