extends Node3D
class_name HumanoidModel

signal on_hurtbox_touched_victim(_model:HumanoidModel, _source:Area3D, _victim:Area3D)

var _moves:Dictionary = {
	"jab" = {
		anim = "jab",
		moveType = MOVE_TYPE_SINGLE,
		hitTickLH = 0.0333,
		hitTickLHOff = 0.1,
		damage = 1.0,
		juggleStrength = 0.0,
		launchStrength = 0.0,
		sweepStrength = 0.0,
		hitHeight = Mobs.HIT_HEIGHT_MID | Mobs.HIT_HEIGHT_HIGH,
		canEvadeCancel = true
	},
	"jab_slow" = {
		anim = "jab_slow",
		moveType = MOVE_TYPE_SINGLE,
		hitTickLH = 0.5,
		damage = 1.0,
		juggleStrength = 0.0,
		launchStrength = 0.0,
		sweepStrength = 0.0,
		hitHeight =Mobs.HIT_HEIGHT_MID,
		canEvadeCancel = true
	},
	"straight" = {
		anim = "straight",
		moveType = MOVE_TYPE_SINGLE,
		hitTickRH = 0.1,
		damage = 1.5,
		juggleStrength = 0.0,
		launchStrength = 0.0,
		sweepStrength = 0.0,
		hitHeight =Mobs.HIT_HEIGHT_MID | Mobs.HIT_HEIGHT_HIGH,
		canEvadeCancel = true
	},
	"hook_front" = {
		anim = "hook_front",
		moveType = MOVE_TYPE_SINGLE,
		hitTickLH = 0.23,
		damage = 2.0,
		juggleStrength = 0.0,
		launchStrength = 0.0,
		sweepStrength = 0.0,
		hitHeight =Mobs.HIT_HEIGHT_MID | Mobs.HIT_HEIGHT_HIGH,
		canEvadeCancel = true
	},
	"hook_back" = {
		anim = "hook_back",
		moveType = MOVE_TYPE_SINGLE,
		hitTickRH = 0.23,
		damage = 2.5,
		juggleStrength = 0.0,
		launchStrength = 0.0,
		sweepStrength = 0.0,
		hitHeight =Mobs.HIT_HEIGHT_MID | Mobs.HIT_HEIGHT_HIGH,
		canEvadeCancel = true
	},
	"uppercut" = {
		anim = "uppercut_charge",
		moveType = MOVE_TYPE_HOLD_SINGLE,
		releaseMove = "uppercut_release",
		hitTickRH = 0.5,
		damage = 2.0,
		juggleStrength = 0.0,
		launchStrength = 0.0,
		sweepStrength = 0.0,
		chargeTime = 1.0,
		chargeMultiplier = 2.0,
		hitHeight =Mobs.HIT_HEIGHT_MID,
		canEvadeCancel = true
	},
	"uppercut_release" = {
		anim = "uppercut_release",
		moveType = MOVE_TYPE_SINGLE,
		hitTickRH = 0.1,
		damage = 2.0,
		juggleStrength = 4.5,
		launchStrength = 0.0,
		sweepStrength = 0.0,
		hitHeight =Mobs.HIT_HEIGHT_MID,
		canEvadeCancel = true
	},
	"no_shadow_kick_charge" = {
		anim = "no_shadow_charge",
		moveType = MOVE_TYPE_HOLD_MULTI,
		releaseMove = "no_shadow_kick_release",
		damage = 2.0,
		juggleStrength = 0.0,
		launchStrength = 1.0,
		sweepStrength = 0.0,
		hitHeight = Mobs.HIT_HEIGHT_LOW | Mobs.HIT_HEIGHT_MID,
		canEvadeCancel = true
	},
	"no_shadow_kick_release" = {
		anim = "no_shadow_release",
		moveType = MOVE_TYPE_RELEASE_MULTI,
		hitTickRF = 0.05,
		damage = 2.0,
		juggleStrength = 2.0,
		launchStrength = 0.0,
		sweepStrength = 0.0,
		flinchStrength = 2.0,
		hitHeight = Mobs.HIT_HEIGHT_LOW | Mobs.HIT_HEIGHT_MID,
		canEvadeCancel = true
	},
	"haymaker_loop" = {
		anim = "haymakers",
		moveType = MOVE_TYPE_SINGLE,
		hitTickRH = 0.3667,
		hitTickLH = 1.0,
		damage = 3.0,
		juggleStrength = 0.0,
		launchStrength = 0.0,
		sweepStrength = 0.0,
		hitHeight = Mobs.HIT_HEIGHT_HIGH | Mobs.HIT_HEIGHT_MID,
		canEvadeCancel = true
	},
	"rolling_punches_repeatable" = {
		anim = "rolling_punches_repeatable",
		moveType = MOVE_TYPE_SINGLE,
		hitTickLH = 0.05,
		hitTickRH = 0.1,
		damage = 0.25,
		juggleStrength = 0.0,
		launchStrength = 0.0,
		sweepStrength = 0.0,
		hitHeight = Mobs.HIT_HEIGHT_MID,
		canEvadeCancel = true
	},
	"spin_back_kick" = {
		anim = "spin_back_kick",
		moveType = MOVE_TYPE_SINGLE,
		hitTickRF = 0.3,
		damage = 0.25,
		juggleStrength = 0.0,
		launchStrength = 1.0,
		sweepStrength = 0.0,
		hitHeight = Mobs.HIT_HEIGHT_MID,
		canEvadeCancel = false
	},
	"flying_kick" = {
		#anim = "air_spin_kicks",
		anim = "flying_kick",
		moveType = MOVE_TYPE_DESCENDING,
		hitTickRF = 0.0333,
		hitTickRFoff = 4,
		damage = 0.25,
		juggleStrength = 0.0,
		launchStrength = 1.0,
		sweepStrength = 0.0,
		hitHeight = Mobs.HIT_HEIGHT_HIGH,
		canEvadeCancel = false
	},
	"slide_kick" = {
		#anim = "air_spin_kicks",
		anim = "slide_kick",
		moveType = MOVE_TYPE_SLIDE,
		hitTickRF = 0.0333,
		hitTickRFoff = 4,
		damage = 0.25,
		juggleStrength = 1.0,
		launchStrength = 0.0,
		sweepStrength = 0.0,
		hitHeight = Mobs.HIT_HEIGHT_LOW,
		canEvadeCancel = false
	},
	"air_snap_kicks" = {
		#anim = "air_spin_kicks",
		anim = "air_snap_kicks",
		moveType = MOVE_TYPE_SINGLE,
		#moveType = MOVE_TYPE_DESCENDING,
		hitTickLF = 0.1,
		hitTickRF = 0.3,
		damage = 1.25,
		juggleStrength = 4.5,
		launchStrength = 0.0,
		sweepStrength = 0.0,
		hitHeight = Mobs.HIT_HEIGHT_MID,
		canEvadeCancel = false
	},
	"air_split_kicks" = {
		#anim = "air_spin_kicks",
		anim = "air_split_kick",
		moveType = MOVE_TYPE_SINGLE,
		hitTickLF = 0.3,
		hitTickRF = 0.3,
		damage = 1.25,
		juggleStrength = 0.0,
		launchStrength = 0.5,
		sweepStrength = 0.0,
		hitHeight = Mobs.HIT_HEIGHT_MID,
		canEvadeCancel = false
	},
	"air_axe_kick" = {
		#anim = "air_spin_kicks",
		anim = "air_axe_kick",
		moveType = MOVE_TYPE_SINGLE,
		hitTickRF = 0.2667,
		hitTickRFoff = 0.3667,
		damage = 1.25,
		juggleStrength = -10.0,
		launchStrength = 0.0,
		sweepStrength = 0.0,
		hitHeight = Mobs.HIT_HEIGHT_MID | Mobs.HIT_HEIGHT_HIGH,
		canEvadeCancel = false
	},
	"air_spin_back_kick" = {
		anim = "spin_back_kick",
		moveType = MOVE_TYPE_SINGLE,
		hitTickRF = 0.3,
		damage = 0.25,
		juggleStrength = 0.0,
		launchStrength = 1.0,
		sweepStrength = 0.0,
		hitHeight = Mobs.HIT_HEIGHT_MID | Mobs.HIT_HEIGHT_HIGH,
		canEvadeCancel = false
	},
	"dive_kick" = {
		#anim = "air_spin_kicks",
		anim = "dive_kick",
		moveType = MOVE_TYPE_DESCENDING,
		#hitTickLF = 0.3,
		hitTickRF = 0.3,
		damage = 1.25,
		juggleStrength = 0.0,
		launchStrength = 0.5,
		sweepStrength = 0.0,
		hitHeight = Mobs.HIT_HEIGHT_MID,
		canEvadeCancel = false
	},
	"sweep" = {
		anim = "sweep",
		moveType = MOVE_TYPE_SINGLE,
		hitTickRF = 0.33,
		hitTickRFoff = 0.5,
		damage = 0.25,
		juggleStrength = 0.0,
		launchStrength = 0.0,
		sweepStrength = 1.0,
		hitHeight = Mobs.HIT_HEIGHT_LOW,
		canEvadeCancel = false
	},
	"somersault_backward" = {
		anim = "somersault_backward",
		moveType = MOVE_TYPE_SINGLE,
		hitTickLF = 0.43,
		hitTickLFoff = 0.6,
		damage = 0.25,
		juggleStrength = 7.0,
		launchStrength = 0.0,
		sweepStrength = 0.0,
		hitHeight = Mobs.HIT_HEIGHT_LOW | Mobs.HIT_HEIGHT_MID | Mobs.HIT_HEIGHT_HIGH,
		canEvadeCancel = false
	},
	"taunt_bring_it_on" = {
		anim = "taunt_combat_1",
		moveType = MOVE_TYPE_SINGLE,
		damage = 0.0,
		juggleStrength = 0.0,
		launchStrength = 0.0,
		sweepStrength = 0.0,
		hitHeight = Mobs.HIT_HEIGHT_MID,
		canEvadeCancel = true
	}
}

const EVADE_SPEED:float = 9.5
const STATIC_EVADE_TIME:float = 0.25
const STATIC_EVADE_LOCKOUT_TIME:float = 0.1
const MOVING_EVADE_TIME:float = 0.3
const MOVING_EVADE_LOCKOUT_TIME:float = 0.1
const FLINCH_EVADE_LOCKOUT_TIME:float = 0.1

const ATK_HOLD_BIT_0:int = (1 << 0)
const ATK_HOLD_BIT_1:int = (1 << 1)
const ATK_HOLD_BIT_2:int = (1 << 2)

const ANIM_IDLE:String = "_idle"
const ANIM_IDLE_AGILE:String = "running" # "_idle_agile"
const ANIM_EVADE_STATIC_1:String = "evade_static_1"
const ANIM_EVADE_STATIC_2:String = "evade_static_2"

const ANIM_FLINCH:String = "flinch"
const ANIM_DAZED:String = "dazed"

const MOVE_TYPE_SINGLE:int = 0
const MOVE_TYPE_HOLD_SINGLE:int = 1
const MOVE_TYPE_HOLD_MULTI:int = 2
const MOVE_TYPE_DESCENDING:int = 3
const MOVE_TYPE_SLIDE:int = 4
const MOVE_TYPE_RELEASE_MULTI:int = 5

const MOVE_JAB:String = "jab"
const MOVE_SPIN_BACK_KICK:String = "spin_back_kick"
const MOVE_UPPERCUT:String = "uppercut"
const MOVE_ROLLING_PUNCHES:String = "rolling_punches_repeatable"
const MOVE_SWEEP:String = "sweep"

const BLINK_TIME:float = 0.05

const MAX_AIR_MOVES:int = 1

const STANCE_COMBAT:int = 0
const STANCE_AGILE:int = 1

@onready var _animator:AnimationPlayer = $AnimationPlayer
@onready var _leftHandArea:HurtboxArea3D = $hitboxes/hand_l/Area3D
@onready var _rightHandArea:HurtboxArea3D = $hitboxes/hand_r/Area3D
@onready var _leftFootArea:HurtboxArea3D = $hitboxes/foot_l/Area3D
@onready var _rightFootArea:HurtboxArea3D = $hitboxes/foot_r/Area3D
@onready var _launchedAoE:Area3D = $hitboxes/launched_aoe
@onready var _hitInfo:HitInfo = $HitInfo

var debugLevel:int = 0
var _airMoves:int = 1

var _charBody:CharacterBody3D = null
var _hitbox:Area3D = null
var _teamId:int = 0

var _totalThinkTime:float = 0.0
var _state:int = Mobs.STATE_NEUTRAL
var _stateTick:float = 0.0
var _stateTime:float = 0.0

var _stance:int = STANCE_AGILE
var _pendingStance:int = STANCE_COMBAT
var _stanceMoveSpeed:float = 3.0
var _stanceIdleAnim:String = ANIM_IDLE
var _stanceJumpSpeed:float = 3.0

var _evadeDir:Vector3 = Vector3()
var _evadeLockoutTick:float = 0.0
var _lookYaw:float = 0.0
var _currentMoveName:String = ""
var _releaseMoveName:String = ""
var _atkHold:int = 0
var _lastMoveName:String = ""
var _lastMoveEndTime:float = 0.0
var _multiHitRepeats:int = 0
var _lastChargeMultiplier:float = 1.0
var _lastMoveMovementMode:int = Mobs.MOVE_MOVE_MODE_SUSPEND

var _bufferedMoveName:String = ""
var _bufferedMoveTick:float = 0.0
var _bufferedMoveSpeedMul:float = 1.0
var _bufferedMoveHoldButtons:int = 0
var _bufferedYaw:float = 0.0
#var _nextMoveYaw:float = 0.0

var _blinkTick:float = 0.0
var _isBlinking:bool = false

var _weightClass:int = Mobs.WEIGHT_CLASS_FODDER

func _ready() -> void:
	_airMoves = MAX_AIR_MOVES
	_animator.connect("animation_changed", _on_animation_changed)

	_leftHandArea.connect("on_check_for_victims", _on_check_for_victims)
	_rightHandArea.connect("on_check_for_victims", _on_check_for_victims)
	_leftFootArea.connect("on_check_for_victims", _on_check_for_victims)
	_rightFootArea.connect("on_check_for_victims", _on_check_for_victims)

	_leftHandArea.connect("on_hit_victim", _on_hit_victim)
	_rightHandArea.connect("on_hit_victim", _on_hit_victim)
	_leftFootArea.connect("on_hit_victim", _on_hit_victim)
	_rightFootArea.connect("on_hit_victim", _on_hit_victim)

func attach_character_body(charBody:CharacterBody3D, hitbox:Area3D, newTeamId:int) -> void:
	_charBody = charBody
	_hitbox = hitbox
	_teamId = newTeamId

func set_stats(fighterWeightClass:int = 0) -> void:
	_weightClass = fighterWeightClass

# queued animation has started
func _on_animation_changed(_oldName:String, _newName:String) -> void:
	if _newName == ANIM_IDLE || _newName == ANIM_IDLE_AGILE:
		#_finish_move()
		pass

func get_last_move() -> String:
	return _lastMoveName

func get_time_since_last_move() -> float:
	return _totalThinkTime - _lastMoveEndTime

# 'play' was called
func _on_current_animation_changed(_anim:String) -> void:
	pass

func get_current_move_name() -> String:
	if _state != Mobs.STATE_PERFORMING_MOVE:
		return ""
	return _currentMoveName

# stance specific idle animations
func set_idle_to_agile() -> void:
	_stanceIdleAnim = ANIM_IDLE_AGILE

func set_idle_to_combat() -> void:
	_stanceIdleAnim = ANIM_IDLE

func play_idle() -> void:
	_animator.play(_stanceIdleAnim)

func get_debug_text() -> String:
	var txt:String = "State: " + str(_state)
	if _state == Mobs.STATE_EVADE_MOVING || _state == Mobs.STATE_EVADE_STATIC:
		txt += "\nEvade: " + str(_stateTick)
	else:
		if _currentMoveName != "":
			txt += "\nMove: " + str(_currentMoveName)
			var move = _moves[_currentMoveName]
			txt += "\nHit height " + str(move.hitHeight)
		else:
			txt += "\nNo move"
		if _lastMoveName != "" && get_time_since_last_move() < 0.25:
			txt += "\nLast Move: " + str(_lastMoveName)
		else:
			txt += "\nNo last move"	
	return txt

func set_show_attack_indicators(flag:bool) -> void:
	_leftHandArea.showAttackIndicators = flag
	_rightHandArea.showAttackIndicators = flag
	_leftFootArea.showAttackIndicators = flag
	_rightFootArea.showAttackIndicators = flag

##############################################################
# hittin' and hurtin'
##############################################################

func _on_check_for_victims(_hurtbox:HurtboxArea3D, _victims:Array[Area3D]) -> void:
	_hitInfo.launchYawRadians = _lookYaw - PI
	_hitInfo.teamId = _teamId
	var num:int = _victims.size()
	for i in range(0, num):
		var victim:Area3D = _victims[i]
		if victim == _hitbox:
			# self hit - ignore
			continue
		if victim.has_method("hit"):
			victim.hit(_hitInfo)
		#on_hurtbox_touched_victim.emit(self, _hurtbox, victim)

func _setup_hit_info(hurtBox:HurtboxArea3D, moveName:String) -> void:
	_hitInfo.launchYawRadians = _lookYaw - PI
	if moveName == "air_split_kicks":
		match hurtBox.limb:
			HurtboxArea3D.Limb.LeftHand, HurtboxArea3D.Limb.LeftFoot:
				_hitInfo.launchYawRadians += (PI * 0.5)
			HurtboxArea3D.Limb.RightHand, HurtboxArea3D.Limb.RightFoot:
				_hitInfo.launchYawRadians -= (PI * 0.5)
	_hitInfo.teamId = _teamId

func _on_hit_victim(_hurtbox:HurtboxArea3D, victim:Area3D) -> void:
	_setup_hit_info(_hurtbox, _currentMoveName)
	if victim == _hitbox:
		# self hit - ignore
		return
	if victim.has_method("hit"):
		victim.hit(_hitInfo)

func hit(_incomingHit:HitInfo) -> int:
	if _incomingHit.teamId == self._teamId:
		return -2
	
	var hitsLow:bool = (_incomingHit.hitHeight & Mobs.HIT_HEIGHT_LOW) != 0
	
	
	# check if move can hit first
	if _state == Mobs.STATE_EVADE_MOVING || _state == Mobs.STATE_EVADE_STATIC && !hitsLow:
		if debugLevel > 0:
			print(str(self) + " evaded")
		return -1
	
	if !hitsLow && _currentMoveName == "sweep":
		if debugLevel > 0:
			print(str(self) + " evaded low")
		return -1
	
	# 0.5 is falling-over part of knockdown animation
	if !hitsLow && _state == Mobs.STATE_FALLEN && _animator.current_animation_position > 0.5:
		if debugLevel > 0:
			print(str(self) + " attack too high")
		return -1

	#print(str(self) + " hit")
	if _incomingHit.launchStrength > 0.0:
		#print("Launched!")
		# don't relaunch otherwise multi-directional attacks interfer
		if _state != Mobs.STATE_LAUNCHED:
			begin_launch(_incomingHit.launchYawRadians, _incomingHit.teamId)
	elif _state == Mobs.STATE_JUGGLED:
		begin_juggle(4.0)
	elif _incomingHit.juggleStrength > 0.0:
		#print("Juggled!")
		begin_juggle(10.0)
	elif _incomingHit.juggleStrength < 0.0:
		# ground splat into juggle
		begin_juggle(10.0)
	elif _incomingHit.sweepStrength > 0.0:
		#print("Swept!")
		if _weightClass == Mobs.WEIGHT_CLASS_PLAYER:
			begin_flinch(_incomingHit.flinchStrength)
		else:
			begin_fallen()
	else:
		begin_flinch(_incomingHit.flinchStrength)
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
func begin_move(moveName:String, speedModifier:float = 1.0, atkHold:int = 0) -> bool:
	if _state != Mobs.STATE_NEUTRAL:
		return false
	if !_moves.has(moveName):
		print("move " + moveName + " not found!")
		return false
	if !_charBody.is_on_floor() && _airMoves == 0:
		return false
	if is_performing_move():
		return false
	return _overwrite_move(moveName, speedModifier, atkHold)

# start a move with no checks
func _overwrite_move(moveName:String, speedModifier:float = 1.0, atkHold:int = 0, chargeMoveScale:float = 1.0) -> bool:
	# oi no dividing by zero
	if speedModifier < 0.1:
		speedModifier = 0.1
	elif speedModifier > 8.0:
		speedModifier = 8.0
	#print("Begin move " + moveName)
	if debugLevel > 0:
		print("Start " + str (moveName))
	var move:Dictionary = _moves[moveName]
	_currentMoveName = moveName
	set_look_yaw(_bufferedYaw)
	_stateTime = ZqfUtils.safe_dict_f(move, "chargeTime", 1.0)
	_lastChargeMultiplier = ZqfUtils.safe_dict_f(move, "chargeMultiplier", 1.0)
	_lastMoveMovementMode = ZqfUtils.safe_dict_i(move, "movementMode", Mobs.MOVE_MOVE_MODE_SUSPEND)
	if !_charBody.is_on_floor():
		_airMoves -= 1
	match _lastMoveMovementMode:
		Mobs.MOVE_MOVE_MODE_SUSPEND, Mobs.MOVE_MOVE_MODE_CANCEL_AND_FALL:
			_charBody.velocity = Vector3()

	print("Charge mul " + str(_lastChargeMultiplier))
	if move.moveType == MOVE_TYPE_HOLD_SINGLE || move.moveType == MOVE_TYPE_HOLD_MULTI:
		_state = Mobs.STATE_PERFORMING_MOVE
		_stateTick = 0.0
		_atkHold = atkHold
		_releaseMoveName = move.releaseMove
		_animator.play(move.anim, -1, speedModifier)
		return true
	_state = Mobs.STATE_PERFORMING_MOVE
	_stateTick = 0.0
	_animator.play(move.anim, -1, speedModifier)
	if move.moveType != MOVE_TYPE_RELEASE_MULTI && move.moveType != MOVE_TYPE_DESCENDING:
		_animator.queue(_stanceIdleAnim)

	# required
	_hitInfo.damage = move.damage * chargeMoveScale
	_hitInfo.juggleStrength = move.juggleStrength * chargeMoveScale
	_hitInfo.launchStrength = move.launchStrength * chargeMoveScale
	_hitInfo.sweepStrength = move.sweepStrength * chargeMoveScale
	# every move should have a little flinch effect at least
	_hitInfo.flinchStrength = ZqfUtils.safe_dict_f(move, "flinchStrength", 1.0) * chargeMoveScale
	_hitInfo.hitHeight = move.hitHeight

	# variable which are on
	_leftHandArea.check_start_from_move(move, "hitTickLH", "hitTickLHoff", speedModifier)
	_rightHandArea.check_start_from_move(move, "hitTickRH", "hitTickRHoff", speedModifier)
	_leftFootArea.check_start_from_move(move, "hitTickLF", "hitTickLFoff", speedModifier)
	_rightFootArea.check_start_from_move(move, "hitTickRF", "hitTickRFoff", speedModifier)

	return true

func clear_move_buffer() -> void:
	_bufferedMoveName = ""

func buffer_move(moveName:String, speedMul:float = 1.0, holdButton:int = 0) -> void:
	# deny move buffering if off ground
	if _airMoves <= 0:
		clear_move_buffer()
		return
	_bufferedMoveName = moveName
	_bufferedMoveTick = 0.0
	_bufferedMoveSpeedMul = speedMul
	_bufferedMoveHoldButtons = holdButton

func buffer_move_yaw(yaw:float) -> void:
	_bufferedYaw = yaw

func _finish_move() -> void:
	_hitInfo.damage = 1.0
	_hitInfo.juggleStrength = 0.0
	_hitInfo.launchStrength = 0.0
	if _currentMoveName != "":
		if debugLevel > 0:
			print("Enter idle move clear")
		_lastMoveName = _currentMoveName
		_lastMoveEndTime = _totalThinkTime
		_clear_current_move()
	_all_hurtboxes_off()

func is_performing_move() -> bool:
	var anim:String = _animator.current_animation
	if anim == ANIM_IDLE || anim == "running":
		return false
	if anim == ANIM_EVADE_STATIC_1 || anim == ANIM_EVADE_STATIC_2:
		return false
	return anim != ""

func _can_change_stance() -> bool:
	if self.is_performing_move():
		return false
	return true

func _clear_current_move() -> void:
	_currentMoveName = ""

##############################################################
# Begin Evading - can interupts other actions
##############################################################

func _evade_start() -> void:
	_all_hurtboxes_off()
	_clear_current_move()
	_lastMoveName = ""

func _play_random_evade_anim() -> void:
	var curAnim:String = _animator.current_animation
	if curAnim == ANIM_EVADE_STATIC_1:
		_animator.play(ANIM_EVADE_STATIC_2)
	elif curAnim == ANIM_EVADE_STATIC_2:
		_animator.play(ANIM_EVADE_STATIC_1)
	else:
		if randf() > 0.5:
			_animator.play(ANIM_EVADE_STATIC_1)
		else:
			_animator.play(ANIM_EVADE_STATIC_2)
	_animator.queue(_stanceIdleAnim)

func begin_evade(dir:Vector3) -> bool:
	if _evadeLockoutTick > 0.0:
		return false
	match _state:
		Mobs.STATE_DAZED, Mobs.STATE_FALLEN, Mobs.STATE_JUGGLED, Mobs.STATE_LAUNCHED:
			return false
	if _moves.has(_currentMoveName) && !_moves[_currentMoveName].canEvadeCancel:
		return false
	if !_charBody.is_on_floor():
		print("Cannot air evade!")
		return false
	# okay, we can evade

	_evadeDir = dir
	set_look_yaw(_bufferedYaw)
	if dir.is_zero_approx():
		_play_random_evade_anim()
		_charBody.velocity = Vector3()
		_stateTime = STATIC_EVADE_TIME
		_stateTick = _stateTime
		_evadeLockoutTick = STATIC_EVADE_LOCKOUT_TIME
		_state = Mobs.STATE_EVADE_STATIC
	else:
		if dir.x < 0:
			_animator.play(ANIM_EVADE_STATIC_1)
			_animator.queue(_stanceIdleAnim)
		elif dir.x > 0:
			_animator.play(ANIM_EVADE_STATIC_2)
			_animator.queue(_stanceIdleAnim)
		else:
			_play_random_evade_anim()
		_charBody.velocity = dir * EVADE_SPEED
		_stateTime = MOVING_EVADE_TIME
		_stateTick = _stateTime
		_evadeLockoutTick = MOVING_EVADE_LOCKOUT_TIME
		_state = Mobs.STATE_EVADE_MOVING
	_evade_start()
	return true

##############################################################
# Begin disabling hit responses
##############################################################

func begin_flinch(weight:float) -> void:
	_all_hurtboxes_off()
	_clear_current_move()
	_animator.stop()
	_animator.play("flinch")
	_animator.queue(_stanceIdleAnim)
	_state = Mobs.STATE_HIT_FLINCHING
	_evadeLockoutTick = FLINCH_EVADE_LOCKOUT_TIME
	_stateTime = 0.25 * weight
	_stateTick = _stateTime

func begin_dazed() -> void:
	_animator.play("dazed")
	_state = Mobs.STATE_DAZED
	_stateTime = 10.0
	_stateTick = _stateTime

func begin_juggle(strength:float = 10.0) -> void:
	strength = clampf(strength, 0.1, 25.0)
	_all_hurtboxes_off()
	_clear_current_move()
	_animator.play("launched")
	_state = Mobs.STATE_JUGGLED
	_charBody.velocity = Vector3(0, strength, 0)

func begin_fallen() -> void:
	if _state == Mobs.STATE_FALLEN:
		return
	_all_hurtboxes_off()
	_clear_current_move()
	_animator.play("knockdown")
	_state = Mobs.STATE_FALLEN
	match _weightClass:
		Mobs.WEIGHT_CLASS_PLAYER:
			_stateTime = 0.625
		_:
			_stateTime = 4.0
	_stateTick = _stateTime

func begin_rising() -> void:
	_all_hurtboxes_off()
	_clear_current_move()
	_animator.play("fallen_to_idle")
	_animator.queue(_stanceIdleAnim)
	_state = Mobs.STATE_RISING
	_stateTime = 1.0
	_stateTick = _stateTime

func begin_launch(yaw:float, launchingTeamId:int = 0) -> void:
	if _state == Mobs.STATE_LAUNCHED:
		return
	if launchingTeamId == _teamId:
		return
	
	_all_hurtboxes_off()
	_clear_current_move()

	# for the duration of launch our hit info becomes a player hit to launch
	# other enemies
	_hitInfo.launchYawRadians = yaw
	_hitInfo.launchStrength = 1.0
	_hitInfo.teamId = launchingTeamId

	if debugLevel > 0:
		_animator.play("launched")
	_state = Mobs.STATE_LAUNCHED
	var speed:float = 20.0
	match _weightClass:
		Mobs.WEIGHT_CLASS_PLAYER:
			_stateTime = 0.2
			speed = 15.0
		_:
			_stateTime = 2.0
	_stateTick = _stateTime
	_charBody.velocity = Vector3(-sin(yaw) * speed, 0, -cos(yaw) * speed)
	set_look_yaw(yaw + PI)
	_launchedAoE.monitoring = true

func set_blinking(flag:bool) -> void:
	if !_isBlinking && flag:
		_blinkTick = BLINK_TIME
	_isBlinking = flag
	if !_isBlinking:
		self.visible = true

func _process(_delta:float) -> void:
	_totalThinkTime += _delta
	if _evadeLockoutTick > 0.0:
		_evadeLockoutTick -= _delta
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

func set_desired_stance(newStance:int) -> void:
	_pendingStance = newStance

func _change_stance(newStance:int) -> void:
	_stance = newStance
	match newStance:
		STANCE_AGILE:
			_stanceMoveSpeed = 8.0
			self.set_idle_to_agile()
			if _state == Mobs.STATE_NEUTRAL:
				self.play_idle()
		_:
			# default - combat
			_stanceMoveSpeed = 3.0
			self.set_idle_to_combat()
			if _state == Mobs.STATE_NEUTRAL:
				self.play_idle()

func get_stance() -> int:
	return _stance

func get_state() -> int:
	return _state

func check_stance() -> int:
	if _stance != _pendingStance && _can_change_stance():
		_change_stance(_pendingStance)
	return _stance

########################################################
# Frame tick
########################################################

func _step_movement(_delta:float, _pushDir:Vector3, pushSpeedCap:float, jumpSpeed:float) -> void:
	
	var isOnFloor:bool = _charBody.is_on_floor()
	var verticalSpeed:float = _charBody.velocity.y

	# calc horizontal velocity
	var horizontalVelocity:Vector3 = _charBody.velocity
	horizontalVelocity.y = 0.0
	var flatVelocityCap:float = horizontalVelocity.length()
	if flatVelocityCap < pushSpeedCap || isOnFloor:
		flatVelocityCap = pushSpeedCap
	
	var dragAccel:float = 15.0
	var isPushing:bool = _pushDir.x != 0 && _pushDir.z != 0
	if isOnFloor:
		dragAccel = 50.0

	if isPushing:
		# pushing
		if isOnFloor:
			horizontalVelocity += (_pushDir * (80.0 * _delta))
	else:
		# no push - drag
		var drag:Vector3 = horizontalVelocity.normalized()
		drag = -drag
		drag *= dragAccel * _delta
		horizontalVelocity += drag
		# force stop
		if horizontalVelocity.length_squared() <= drag.length_squared():
			horizontalVelocity.x = 0
			horizontalVelocity.z = 0
	if horizontalVelocity.length() > flatVelocityCap:
		horizontalVelocity = horizontalVelocity.normalized() * flatVelocityCap

	var finalVelocity:Vector3 = horizontalVelocity
	finalVelocity.y = verticalSpeed

	if isOnFloor && _pushDir.y > 0: # jump
		finalVelocity.y = jumpSpeed
	else: # fall
		finalVelocity.y = verticalSpeed + (-20.0 * _delta)
	_charBody.velocity = finalVelocity
	_charBody.move_and_slide()

	pass

func _process_agile_stance(_delta: float, _pushDir:Vector3, _desiredYaw:float) -> void:
	_step_movement(_delta, _pushDir, _stanceMoveSpeed, 7.5)
	
	var horizontalVelocity:Vector3 = _charBody.velocity
	horizontalVelocity.y = 0.0
	# look in dir of movement
	if horizontalVelocity.x != 0 && horizontalVelocity.z != 0:
		var modelYaw:float = atan2(-horizontalVelocity.x, -horizontalVelocity.z)
		_desiredYaw = modelYaw
		set_look_yaw(_desiredYaw)
	
	# start moves
	if _bufferedMoveName != "":
		if begin_move(_bufferedMoveName, _bufferedMoveSpeedMul, _bufferedMoveHoldButtons):
			clear_move_buffer()
			return

func _process_neutral_combat_stance(_delta:float, _pushDir:Vector3, _desiredYaw:float) -> void:
	if is_performing_move():
		return
	set_look_yaw(_desiredYaw)
	_step_movement(_delta, _pushDir, _stanceMoveSpeed, 5.0)
	if _bufferedMoveName != "":
		if begin_move(_bufferedMoveName, _bufferedMoveSpeedMul, _bufferedMoveHoldButtons):
			clear_move_buffer()
			return

func custom_physics_process(_delta: float, _pushDir:Vector3, _desiredYaw:float, buttons:int) -> void:
	if _charBody.is_on_floor():
		_airMoves = MAX_AIR_MOVES
	if _bufferedMoveName != "":
		_bufferedMoveTick += _delta
		if _bufferedMoveTick > 0.5:
			clear_move_buffer()
	
	match _state:
		Mobs.STATE_NEUTRAL:
			match _stance:
				STANCE_AGILE:
					_process_agile_stance(_delta, _pushDir, _desiredYaw)
				_:
					_process_neutral_combat_stance(_delta, _pushDir, _desiredYaw)
		Mobs.STATE_PERFORMING_MOVE:
			_stateTick += _delta
			if !_moves.has(_currentMoveName):
				# err?
				_state = Mobs.STATE_NEUTRAL
				return
			var move:Dictionary = _moves[_currentMoveName]
			var moveType:int = move.moveType
			
			#match _lastMoveMovementMode:
			#	Mobs.MOVE_MOVE_MODE_CANCEL_AND_FALL, Mobs.MOVE_MOVE_MODE_CONTINUE:
			#		_charBody.velocity.y += (-20.0 * _delta)
			#		_charBody.move_and_slide()

			match moveType:
				MOVE_TYPE_HOLD_SINGLE:
					var canRelease:bool = _stateTick > 0.4
					var chargeWeight:float = clampf(_stateTick / _stateTime, 0.0, 1.0)
					var damageMul:float = _lastChargeMultiplier * chargeWeight
					print("tick " + str(_stateTick) + " Charge weight " + str(chargeWeight) + " last mul " + str(_lastChargeMultiplier) + " damage mul " + str(damageMul))
					if (buttons & _atkHold) == 0 && canRelease:
						_overwrite_move(_releaseMoveName, _bufferedMoveSpeedMul, 0, damageMul)
						return
				MOVE_TYPE_HOLD_MULTI:
					set_look_yaw(_desiredYaw)
					if (buttons & _atkHold) == 0 && _stateTick > 0.4:
						_overwrite_move(_releaseMoveName, _bufferedMoveSpeedMul, 0)
						return
				MOVE_TYPE_RELEASE_MULTI:
					set_look_yaw(_desiredYaw)
					if (buttons & _atkHold) != 0:
						_overwrite_move(_releaseMoveName, _bufferedMoveSpeedMul, 0)
						return
				MOVE_TYPE_DESCENDING:
					if _charBody.is_on_floor():
						_finish_move()
						play_idle()
						_state = Mobs.STATE_NEUTRAL
					else:
						var vel:Vector3 = _charBody.velocity
						vel.y += (-20.0 * _delta)
						_charBody.velocity = vel
						_charBody.move_and_slide()
				MOVE_TYPE_SLIDE:
					var vel:Vector3 = _charBody.velocity
					var drag = _charBody.velocity.normalized()
					drag.y = 0
					drag = -drag
					drag *= 10.0 * _delta
					vel += drag
					vel.y += (-20.0 * _delta)
					_charBody.velocity = vel
					_charBody.move_and_slide()
					if debugLevel > 1:
						print(str(_stateTick))
					if _stateTick > 0.75:
						_finish_move()
						play_idle()
						_state = Mobs.STATE_NEUTRAL
				_:
					
					# check if we are in idle
					var anim:String = _animator.current_animation
					if anim == ANIM_IDLE || anim == ANIM_IDLE_AGILE:
						if debugLevel > 0:
							print("Performing move finish - anim is idle")
						_finish_move()
						_state = Mobs.STATE_NEUTRAL
		Mobs.STATE_EVADE_MOVING, Mobs.STATE_EVADE_STATIC:
			var evadeMoveWeight = _stateTick / _stateTime
			evadeMoveWeight = (evadeMoveWeight * 0.75) + 0.25
			var vel:Vector3 = _charBody.velocity
			vel.x = _evadeDir.x * EVADE_SPEED * evadeMoveWeight
			vel.z = _evadeDir.z * EVADE_SPEED * evadeMoveWeight
			vel.y += (-20.0 * _delta)
			_charBody.velocity = vel
			_charBody.move_and_slide()
			_stateTick -= _delta
			if _stateTick <= 0.0:
				_charBody.velocity = Vector3()
				_state = Mobs.STATE_NEUTRAL
		Mobs.STATE_PERFORMING_CHARGE_MOVE:
			if buttons & _atkHold == 0:
				_state = Mobs.STATE_NEUTRAL
				play_idle()
		Mobs.STATE_JUGGLED:
			if _charBody.is_on_floor() && _charBody.velocity.y <= 0.0:
				begin_fallen()
				return
			_charBody.velocity.y += -16.0 * _delta
			_charBody.move_and_slide()
		Mobs.STATE_FALLEN:
			if !_charBody.is_on_floor():
				begin_juggle(1.0)
				return
			_stateTick -= _delta
			if _stateTick <= 0.0:
				_stateTick = 999
				begin_rising()
		Mobs.STATE_RISING:
			_stateTick -= _delta
			if _stateTick <= 0.0:
				_stateTick = 999
				_state = Mobs.STATE_NEUTRAL
		Mobs.STATE_HIT_FLINCHING:
			if !_charBody.is_on_floor():
				begin_juggle(1.0)
				return
			_stateTick -= _delta
			if _stateTick <= 0.0:
				_stateTick = 999
				_state = Mobs.STATE_NEUTRAL
		Mobs.STATE_LAUNCHED:
			_stateTick -= _delta
			if _stateTick <= 0.0:
				_stateTick = 999
				begin_fallen()
				return
			
			var results:KinematicCollision3D = _charBody.move_and_collide(_charBody.velocity * _delta)
			if results != null:
				var l:int = results.get_collision_count()
				for i in range(0, l):
					var obj:Object = results.get_collider(i)
					if "collision_layer" in obj:
						var layer:int = obj.collision_layer
						if (layer & (1 << 0)) == 1:
							begin_fallen()
							break;
				return
			_launch_nearby_teammates()
	
