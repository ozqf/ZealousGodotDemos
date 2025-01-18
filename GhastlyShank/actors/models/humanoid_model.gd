extends Node3D
class_name HumanoidModel

signal on_hurtbox_touched_victim(_model:HumanoidModel, _source:Area3D, _victim:Area3D)

const ANIM_IDLE:String = "_idle"
const ANIM_IDLE_AGILE:String = "running" # "_idle_agile"
const ANIM_EVADE_STATIC_1:String = "evade_static_1"
const ANIM_EVADE_STATIC_2:String = "evade_static_2"
const ANIM_JAB:String = "jab"
const ANIM_SPIN_BACK_KICK:String = "spin_back_kick"
const ANIM_UPPERCUT:String = "uppercut"
const ANIM_ROLLING_PUNCHES:String = "rolling_punches_repeatable"
const ANIM_SWEEP:String = "sweep"

const MOVE_TYPE_SINGLE:int = 0
const MOVE_TYPE_CHARGE:int = 1

const HIT_HEIGHT_HIGH:int = (1 << 0)
const HIT_HEIGHT_MID:int = (1 << 1)
const HIT_HEIGHT_LOW:int = (1 << 2)

var _moves:Dictionary = {
	"jab" = {
		anim = ANIM_JAB,
		moveType = MOVE_TYPE_SINGLE,
		hitTickLH = 0.1,
		damage = 1.0,
		juggleStrength = 0.0,
		launchStrength = 0.0,
		sweepStrength = 0.0,
		hitHeight = HIT_HEIGHT_MID
	},
	"jab_slow" = {
		anim = "jab_slow",
		moveType = MOVE_TYPE_SINGLE,
		hitTickLH = 0.5,
		damage = 1.0,
		juggleStrength = 0.0,
		launchStrength = 0.0,
		sweepStrength = 0.0,
		hitHeight = HIT_HEIGHT_MID
	},
	"uppercut" = {
		anim = ANIM_UPPERCUT,
		moveType = MOVE_TYPE_CHARGE,
		animCharge = "uppercut_charge",
		animRelease = "uppercut_release",
		hitTickRH = 0.5,
		damage = 2.0,
		juggleStrength = 1.0,
		launchStrength = 0.0,
		sweepStrength = 0.0,
		hitHeight = HIT_HEIGHT_MID
	},
	"rolling_punches_repeatable" = {
		anim = ANIM_ROLLING_PUNCHES,
		moveType = MOVE_TYPE_SINGLE,
		hitTickLH = 0.05,
		hitTickRH = 0.1,
		damage = 0.25,
		juggleStrength = 0.0,
		launchStrength = 0.0,
		sweepStrength = 0.0,
		hitHeight = HIT_HEIGHT_MID
	},
	"spin_back_kick" = {
		anim = ANIM_SPIN_BACK_KICK,
		moveType = MOVE_TYPE_SINGLE,
		hitTickRF = 0.3,
		damage = 0.25,
		juggleStrength = 0.0,
		launchStrength = 1.0,
		sweepStrength = 0.0,
		hitHeight = HIT_HEIGHT_MID
	},
	"sweep" = {
		anim = ANIM_SWEEP,
		moveType = MOVE_TYPE_SINGLE,
		hitTickRF = 0.33,
		damage = 0.25,
		juggleStrength = 0.0,
		launchStrength = 0.0,
		sweepStrength = 1.0,
		hitHeight = HIT_HEIGHT_LOW
	},
	"taunt_bring_it_on" = {
		anim = "taunt_combat_1",
		moveType = MOVE_TYPE_SINGLE,
		damage = 0.0,
		juggleStrength = 0.0,
		launchStrength = 0.0,
		sweepStrength = 0.0,
		hitHeight = HIT_HEIGHT_MID
	}
}

const ANIM_FLINCH:String = "flinch"
const ANIM_DAZED:String = "dazed"

const BLINK_TIME:float = 0.05

const STANCE_COMBAT:int = 0
const STANCE_AGILE:int = 1

const STATE_NEUTRAL:int = 0
const STATE_PERFORMING_MOVE:int = 1
const STATE_HIT_FLINCHING:int = 2
const STATE_DAZED:int = 3
const STATE_JUGGLED:int = 4
const STATE_LAUNCHED:int = 5
const STATE_FALLEN:int = 6
const STATE_RISING:int = 7

@onready var _animator:AnimationPlayer = $AnimationPlayer
@onready var _leftHandArea:HurtboxArea3D = $hitboxes/hand_l/Area3D
@onready var _rightHandArea:HurtboxArea3D = $hitboxes/hand_r/Area3D
@onready var _leftFootArea:HurtboxArea3D = $hitboxes/foot_l/Area3D
@onready var _rightFootArea:HurtboxArea3D = $hitboxes/foot_r/Area3D
@onready var _launchedAoE:Area3D = $hitboxes/launched_aoe
@onready var _hitInfo:HitInfo = $HitInfo

var _charBody:CharacterBody3D = null
var _hitbox:Area3D = null

var _state:int = STATE_NEUTRAL
var _stance:int = STANCE_COMBAT
var _stateTick:float = 0.0
var _stateTime:float = 0.0
var _lookYaw:float = 0.0
var _currentMoveName:String = ""
var _nextMoveYaw:float = 0.0

var _idleAnim:String = ANIM_IDLE
var _blinkTick:float = 0.0
var _isBlinking:bool = false

func _ready() -> void:
	_leftHandArea.connect("on_check_for_victims", _on_check_for_victims)
	_rightHandArea.connect("on_check_for_victims", _on_check_for_victims)
	_leftFootArea.connect("on_check_for_victims", _on_check_for_victims)
	_rightFootArea.connect("on_check_for_victims", _on_check_for_victims)

func attach_character_body(charBody:CharacterBody3D, hitbox:Area3D) -> void:
	_charBody = charBody
	_hitbox = hitbox

# queued animation has started
func _on_animation_changed(_oldName:String, _newName:String) -> void:
	if _newName == ANIM_IDLE || _newName == ANIM_IDLE_AGILE:
		_hitInfo.damage = 1.0
		_hitInfo.juggleStrength = 0.0
		_hitInfo.launchStrength = 0.0
		_all_hurtboxes_off()

# 'play' was called
func _on_current_animation_changed(_anim:String) -> void:
	pass

# stance specific idle animations
func set_idle_to_agile() -> void:
	_idleAnim = ANIM_IDLE_AGILE

func set_idle_to_combat() -> void:
	_idleAnim = ANIM_IDLE

func play_idle() -> void:
	_animator.play(_idleAnim)

##############################################################
# hittin' and hurtin'
##############################################################

func _on_check_for_victims(_hurtbox:HurtboxArea3D, _victims:Array[Area3D]) -> void:
	_hitInfo.launchYawRadians = _lookYaw - PI
	var num:int = _victims.size()
	for i in range(0, num):
		var victim:Area3D = _victims[i]
		if victim == _hitbox:
			# self hit - ignore
			continue
		if victim.has_method("hit"):
			victim.hit(_hitInfo)
		#on_hurtbox_touched_victim.emit(self, _hurtbox, victim)

func hit(_incomingHit:HitInfo) -> int:
	print(str(self) + " hit")
	if _incomingHit.launchStrength > 0.0:
		#print("Launched!")
		begin_launch(_incomingHit.launchYawRadians)
	elif _state == STATE_JUGGLED:
		begin_juggle(4.0)
	elif _incomingHit.juggleStrength > 0.0:
		#print("Juggled!")
		begin_juggle(10.0)
	elif _incomingHit.sweepStrength > 0.0:
		#print("Swept!")
		begin_fallen()
	else:
		begin_flinch()
	return 1

func _all_hurtboxes_off() -> void:
	_leftHandArea.clear()
	_rightHandArea.clear()
	_leftFootArea.clear()
	_rightFootArea.clear()
	_launchedAoE.monitoring = false

##############################################################
# begin your rude manoeuvres
##############################################################

# returns true if move started
func begin_move(moveName:String, speedModifier:float = 1.0) -> bool:
	# oi no dividing by zero
	if speedModifier < 0.1:
		speedModifier = 0.1
	elif speedModifier > 8.0:
		speedModifier = 8.0
	#print("Begin move " + moveName)
	if _state != STATE_NEUTRAL:
		return false
	if !_moves.has(moveName):
		print("move " + moveName + " not found!")
		return false
	if is_performing_move():
		return false
	
	var move:Dictionary = _moves[moveName]
	_animator.play(move.anim, -1, speedModifier)
	_currentMoveName = moveName

	# required
	_hitInfo.damage = move.damage
	_hitInfo.juggleStrength = move.juggleStrength
	_hitInfo.launchStrength = move.launchStrength
	_hitInfo.sweepStrength = move.sweepStrength
	_hitInfo.hitHeight = move.hitHeight

	# variable which are on
	_leftHandArea.run(ZqfUtils.safe_dict_f(move, "hitTickLH", 0.0) / speedModifier)
	_rightHandArea.run(ZqfUtils.safe_dict_f(move, "hitTickRH", 0.0) / speedModifier)
	_leftFootArea.run(ZqfUtils.safe_dict_f(move, "hitTickLF", 0.0) / speedModifier)
	var rfTime:float = ZqfUtils.safe_dict_f(move, "hitTickRF", 0.0) / speedModifier
	_rightFootArea.run(rfTime)

	_animator.queue(_idleAnim)
	return true

func is_performing_move() -> bool:
	var anim:String = _animator.current_animation
	if anim == ANIM_IDLE || anim == "running":
		return false
	if anim == ANIM_EVADE_STATIC_1 || anim == ANIM_EVADE_STATIC_2:
		return false
	return anim != ""

##############################################################
# Begin Evading - can interupts other actions
##############################################################
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

func begin_evade_right() -> void:
	_animator.play(ANIM_EVADE_STATIC_2)
	_begin_evade_shared()

##############################################################
# Begin disabling hit responses
##############################################################

func begin_flinch() -> void:
	_animator.play("flinch")
	_animator.queue(_idleAnim)
	_state = STATE_HIT_FLINCHING
	_stateTime = 0.2
	_stateTick = _stateTime

func begin_dazed() -> void:
	_animator.play("dazed")
	_state = STATE_DAZED
	_stateTime = 10.0
	_stateTick = _stateTime

func begin_juggle(strength:float = 10.0) -> void:
	strength = clampf(strength, 0.1, 25.0)
	_all_hurtboxes_off()
	_animator.play("launched")
	_state = STATE_JUGGLED
	_charBody.velocity = Vector3(0, strength, 0)

func begin_fallen() -> void:
	_animator.play("knockdown")
	_state = STATE_FALLEN
	_stateTime = 4.0
	_stateTick = _stateTime

func begin_rising() -> void:
	_animator.play("fallen_to_idle")
	_animator.queue(_idleAnim)
	_state = STATE_RISING
	_stateTime = 1.0
	_stateTick = _stateTime

func begin_launch(yaw:float) -> void:
	if _state == STATE_LAUNCHED:
		return
	_all_hurtboxes_off()
	_hitInfo.launchYawRadians = yaw
	_hitInfo.launchStrength = 1.0
	_animator.play("launched")
	_state = STATE_LAUNCHED
	_stateTime = 2.0
	_stateTick = _stateTime
	_charBody.velocity = Vector3(-sin(yaw) * 20.0, 0, -cos(yaw) * 20.0)
	set_look_yaw(yaw + PI)
	_launchedAoE.monitoring = true

func begin_agile_whirlwind() -> void:
	pass

func set_blinking(flag:bool) -> void:
	if !_isBlinking && flag:
		_blinkTick = BLINK_TIME
	_isBlinking = flag
	if !_isBlinking:
		self.visible = true

func _process(_delta:float) -> void:
	if _isBlinking:
		_blinkTick -= _delta
		if _blinkTick <= 0.0:
			_blinkTick = BLINK_TIME
			self.visible = !self.visible

func set_look_yaw(yawRadians:float) -> void:
	var radians:Vector3 = self.rotation
	radians.y = yawRadians
	radians.y += PI;
	_lookYaw = radians.y
	self.rotation = radians

func look_at_flat(_target:Vector3) -> void:
	var pos:Vector3 = self.global_position
	var yaw:float = ZqfUtils.yaw_between(pos, _target)
	set_look_yaw(yaw)

func _launch_nearby_teammates() -> void:
	var areas:Array[Area3D] = _launchedAoE.get_overlapping_areas()
	for i in range(0, areas.size()):
		var area:Area3D = areas[i]
		if area.has_method("hit"):
			area.hit(_hitInfo)

func custom_physics_process(_delta: float, _pushDir:Vector3, _desiredYaw:float) -> void:
	match _state:
		STATE_NEUTRAL:
			if is_performing_move():
				return
			set_look_yaw(_desiredYaw)
			var verticalSpeed:float = _charBody.velocity.y
			_charBody.velocity = _pushDir * 3.0
			if _charBody.is_on_floor() && _pushDir.y > 0: # jump
				_charBody.velocity.y = 5.0
			else: # fall
				_charBody.velocity.y = verticalSpeed + (-20.0 * _delta)
			_charBody.move_and_slide()
		STATE_JUGGLED:
			if _charBody.is_on_floor() && _charBody.velocity.y <= 0.0:
				begin_fallen()
				return
			_charBody.velocity.y += -16.0 * _delta
			_charBody.move_and_slide()
		STATE_FALLEN:
			if !_charBody.is_on_floor():
				begin_juggle(1.0)
				return
			_stateTick -= _delta
			if _stateTick <= 0.0:
				_stateTick = 999
				begin_rising()
		STATE_RISING:
			_stateTick -= _delta
			if _stateTick <= 0.0:
				_stateTick = 999
				_state = STATE_NEUTRAL
		STATE_HIT_FLINCHING:
			if !_charBody.is_on_floor():
				begin_juggle(1.0)
				return
			_stateTick -= _delta
			if _stateTick <= 0.0:
				_stateTick = 999
				_state = STATE_NEUTRAL
		STATE_LAUNCHED:
			_stateTick -= _delta
			if _stateTick <= 0.0:
				_stateTick = 999
				begin_fallen()
				return
			var result = _charBody.move_and_collide(_charBody.velocity * _delta)
			if result != null:
				begin_fallen()
				return
			_launch_nearby_teammates()
	
