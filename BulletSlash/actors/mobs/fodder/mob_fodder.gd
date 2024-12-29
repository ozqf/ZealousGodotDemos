extends MobBase

const MOB_STATE_IDLE:String = "idle"
const MOB_STATE_STUNNED:String = "stunned"
const MOB_STATE_PARRIED:String = "parried"
const MOB_STATE_CHASE:String = "chase"
const MOB_STATE_ATTACK_MELEE:String = "attack_melee"
const MOB_STATE_ATTACK_RANGED:String = "attack_ranged"
const MOB_STATE_BLOCKING:String = "blocking"
const MOB_STATE_LAUNCHED:String = "launched"

const HIT_REACTION_NONE:int = 0
const HIT_REACTION_HIT_STUN:int = 1
const HIT_REACTION_DAZE:int = 2
const HIT_REACTION_TAKE_AND_BLOCK:int = 3
const HIT_REACTION_LAUNCH:int = 4
const HIT_REACTION_REVENGE:int = 5

const ANIM_IDLE:String = "_idle"
const ANIM_SWING_1:String = "swing_1"
const ANIM_SWING_2:String = "swing_2"
const ANIM_BLOCKING:String = "blocking"
const ANIM_SHOOTING:String = "shooting"

@onready var _animator:AnimationPlayer = $display/AnimationPlayer
@onready var _weapon:Area3D = $display/right_hand/melee_weapon
@onready var _meleeIndicator:MeleeAttackIndicator = $display/right_hand/melee_weapon/melee_attack_indicator
@onready var _rangedIndicator:MeleeAttackIndicator = $display/left_hand/pistol/melee_attack_indicator2
@onready var _hudStatus:MobStatus = $MobStatus
@onready var _gunNode:Node3D = $display/left_hand/pistol
@onready var _enemyViewDetector:Area3D = $enemy_view_detector
var _hitInfo:HitInfo = null

var _state:String = MOB_STATE_IDLE
var _thinkTick:float = 0.0
var _thinkTime:float = 0.5
var _subThinkTick:float = 0.0

var _pushedDir:Vector3 = Vector3.FORWARD
var _parriedSpeed:float = 5.0
var _bladeOn:bool = false
var _windupTargetTrackOn:bool = true

func _ready() -> void:
	super._ready()
	_bodyDisplayRoot = get_node_or_null("display/placehold_mob_model")
	_hitInfo = Game.new_hit_info()
	_hitInfo.damageTeamId = Game.TEAM_ID_ENEMY
	_hitInfo.sourceTeamId = Game.TEAM_ID_ENEMY
	_animator.connect("animation_event", _animation_event)
	_weapon.connect("area_entered", _on_weapon_touched_area)
	_set_blade_on(false)

func _animation_event(eventType:String) -> void:
	#print("Saw anim event type " + str(eventType))
	match eventType:
		AnimationEmitter.EVENT_RIGHT_WEAPON_ON:
			_set_blade_on(true)
		AnimationEmitter.EVENT_RIGHT_WEAPON_OFF:
			_set_blade_on(false)

func _set_blade_on(flag:bool) -> void:
	_bladeOn = flag
	_weapon.set_deferred("monitorable", flag)
	_weapon.set_deferred("monitoring", flag)

func spawn() -> void:
	_healthMax = 40.0
	_defenceStrengthMax = 2.0
	_hitBounceTime = 1.0
	super.spawn()

func is_in_hitstun() -> bool:
	return _state == MOB_STATE_PARRIED || _state == MOB_STATE_STUNNED

func _change_state(newState:String) -> void:
	if _state == newState:
		return
	var oldState:String = _state
	_state = newState
	_meleeIndicator.off()
	_rangedIndicator.off()

	match _state:
		MOB_STATE_CHASE:
			_thinkTime = 0.5
			_defenceless = false
			_animator.play("_idle")
		MOB_STATE_STUNNED:
			_animator.play("stunned")
		MOB_STATE_PARRIED:
			_set_blade_on(false)
			_animator.play("stunned")
		_:
			_defenceless = false
	if _state != MOB_STATE_STUNNED:
		_blockDamage = 0.0
	_thinkTick = 0.0

func _begin_melee_attack() -> void:
	_change_state(MOB_STATE_ATTACK_MELEE)
	_windupTargetTrackOn = true
	_meleeIndicator.run(0.8)
	if randf() > 0.5:
		_animator.play(ANIM_SWING_1)
	else:
		_animator.play(ANIM_SWING_2)
	_thinkTime = _animator.current_animation_length

func _begin_ranged_attack() -> void:
	_change_state(MOB_STATE_ATTACK_RANGED)
	_subThinkTick = 0.5
	_rangedIndicator.run(_subThinkTick)
	_animator.play(ANIM_SHOOTING)
	_thinkTime = _animator.current_animation_length

func _begin_block() -> void:
	_animator.play("blocking")
	_change_state(MOB_STATE_BLOCKING)
	_thinkTime = 0.5
	_thinkTick = 0.0

func _begin_launch() -> void:
	_animator.play("launched")
	_change_state(MOB_STATE_LAUNCHED)
	_thinkTime = 0.5
	_thinkTick = 0.0

func _fire_gun() -> void:
	var t:Transform3D = _gunNode.global_transform
	Game.spawn_gfx_blaster_muzzle(t.origin, -t.basis.z)

func _update_hud_status() -> void:
	var hp:float = _health / _healthMax
	var def:float = _defenceStrength / _defenceStrengthMax
	var stunTime:float = 0.0
	match _state:
		MOB_STATE_STUNNED, MOB_STATE_PARRIED:
			stunTime = _thinkTick / _thinkTime
		_:
			stunTime = 0
	
	_hudStatus.update_stats(hp, def, _power, stunTime, _defenceless)

func _on_weapon_touched_area(area:Area3D) -> void:
	var result:int = Game.try_hit(_hitInfo, area)
	if result == Game.HIT_VICTIM_RESPONSE_PARRIED:
		_pushedDir = _bodyDisplayRoot.global_transform.basis.z
		apply_parry(_hitInfo.responseParryWeight, _hitInfo.responseParryBaseStrength)
		return
	print("Mob response " + str(result))

func apply_parry(weight:float, rootParryStrength:float = 1.0) -> void:
	#print("Mob was parried - weight " + str(weight) + " root strength " + str(rootParryStrength))
	if _state == MOB_STATE_PARRIED:
		var cap:float = 0.5
		if _defenceless:
			cap = 1.0
		if _thinkTick < cap:
			_thinkTick = cap
		return
	_defenceStrength -= rootParryStrength * weight
	if _defenceStrength <= 0.0:
		# "...prepare to die..."
		_defenceless = true
		_defenceStrength = _defenceStrengthMax
		_change_state(MOB_STATE_PARRIED)
		_thinkTime = 2.5
		Game.gfx_parry_impact(self._weapon.global_position)
	else:
		# 'tis but a scratch
		_change_state(MOB_STATE_PARRIED)
		_thinkTime = 0.35

func _calc_received_parry_weight(_incomingHit:HitInfo) -> float:
	var typeWeight:float = 0.5
	match _incomingHit.damageType:
		Game.DAMAGE_TYPE_PUNCH:
			typeWeight = 1.0
	var meleeWindupWeight:float = _meleeIndicator.weight()
	var rangedWindup:float = _rangedIndicator.weight()
	if _state == MOB_STATE_ATTACK_MELEE:
		if _bladeOn:
			print("Danger parry")
			return 1.0 * typeWeight
		print("Windup weight " + str(meleeWindupWeight))
		var chargeWeight:float = meleeWindupWeight * 0.5
		return chargeWeight * typeWeight
	elif _state == MOB_STATE_ATTACK_RANGED:
		var chargeWeight:float = rangedWindup
		return chargeWeight * typeWeight
	return 0.0

func hit(_incomingHit:HitInfo) -> int:
	var rejectResponse:int = check_for_hit_rejection(_incomingHit)
	if rejectResponse <= 0:
		return rejectResponse
	
	_timeSinceLastHit = 0.0
	if _state == MOB_STATE_BLOCKING:
		_blockDamage += _incomingHit.damage
		# reset block time.
		_thinkTick = 0.0
		print("Block damage " + str(_blockDamage))
		Game.gfx_melee_hit_whiff(_incomingHit.position)
		if randf() > 0.5:
			_begin_melee_attack()
			return Game.HIT_VICTIM_RESPONSE_PARRIED
		return Game.HIT_VICTIM_RESPONSE_BLOCKED
	var type:int = _incomingHit.damageType
	var takeHitAndBlock:bool = false

	if !_defenceless:
		_defendedHitsAccumulator += _incomingHit.damage
		var weight:float = clampf(_defendedHitsAccumulator, 0, 5) / 5
		weight *= 0.5
		# roll for entering block
		var chance:float = randf() * 0.5
		if chance + weight > 0.8:
			_begin_block()
	else:
		if type == Game.DAMAGE_TYPE_PUNCH:
			# weeeeeeee
			takeHitAndBlock = false
			_begin_launch()
	#if _defendedHitsAccumulator > 5.0:
	#	_defendedHitsAccumulator = 0.0
	#	takeHitAndBlock = true

	# continue stuns if we are in one
	if _state == MOB_STATE_PARRIED:
		_change_state(MOB_STATE_STUNNED)
	elif _state == MOB_STATE_STUNNED:
		_thinkTick = 0.0
	else:
		var parryWeight:float = _calc_received_parry_weight(_incomingHit)
		if parryWeight > 0.0:
			apply_parry(parryWeight, 1.0)
	

	
	var result:int = super.hit(_incomingHit)
	
	
	
	if _health <= 0.0:
		self.queue_free()
		return 1
	if result > 0:
		if takeHitAndBlock:
			_begin_block()
		else:
			#_change_state(MOB_STATE_STUNNED)
			if !is_in_hitstun():
				_thinkTime = _hitBounceTime
	return result

func _think() -> void:
	match _state:
		#MOB_STATE_CHASE:
		#	_begin_melee_attack()
		MOB_STATE_STUNNED, MOB_STATE_PARRIED:
			if randf() > 0.5:
				_begin_block()
			else:
				_change_state(MOB_STATE_CHASE)
		_:
			var plyr:TargetInfo = Game.get_player_target()
			if plyr != null:
				_change_state(MOB_STATE_CHASE)
			else:
				_change_state(MOB_STATE_IDLE)

func _physics_process(_delta:float) -> void:
	super._physics_process(_delta)
	_update_hud_status()
	_thinkTick += _delta
	if _thinkTick >= _thinkTime:
		_thinkTick = 0.0
		_think()
	match _state:
		MOB_STATE_CHASE:
			if _thinkInfo.target == null:
				_change_state(MOB_STATE_IDLE)
				return
			var inFOV:bool = _enemyViewDetector.has_overlapping_areas()
			#if _timeSinceLastHit < 2.0 && inFOV:
			#	var chance:float = randf()
			#	var rollForBlock:bool = (_defendedHitsAccumulator > 5 || chance > 0.9)
			#	if rollForBlock:
			#		print("Enter block after " + str(_defendedHitsAccumulator) + " defended hits, chance " + str(chance))
			#		_defendedHitsAccumulator = 0
			#		_begin_block()
			#	return
			var tarPos:Vector3 = _thinkInfo.target.t.origin
			_look_toward_flat(tarPos)
			var distSqr:float = _thinkInfo.xzTowardTarget.length_squared()
			var runDist:float = 7.0
			var stopDist:float = 2.0
			if distSqr > (runDist * runDist):
				_step_toward_flat(tarPos, 8.0, _delta)
				if _timeSinceLastHit > 1.0 && (_thinkInfo.target.inAction || !inFOV):
					_begin_ranged_attack()
			elif distSqr > (stopDist * stopDist):
				_step_toward_flat(tarPos, 2.0, _delta)
				if _thinkInfo.target.inAction && _timeSinceLastHit > 1.0 && randf() > 0.8:
					_begin_ranged_attack()
			else:
				if _thinkInfo.target.inAction:
					_begin_block()
				else:
					_begin_melee_attack()
		MOB_STATE_ATTACK_MELEE:
			if _thinkInfo == null || _thinkInfo.target == null:
				return
			if _bladeOn:
				_windupTargetTrackOn = false
			if _windupTargetTrackOn:
				_look_toward_flat(_thinkInfo.target.t.origin)
		MOB_STATE_PARRIED:
			pass
			var weight:float = 1.0 - (_thinkTick / _thinkTime)
			_slide_in_direction(_pushedDir, 1 * weight, _delta)
		MOB_STATE_LAUNCHED:
			var weight:float = 1.0 - (_thinkTick / _thinkTime)
			_slide_in_direction(_pushedDir, 10 * weight, _delta)
		MOB_STATE_ATTACK_RANGED:
			if _thinkInfo.target == null:
				_change_state(MOB_STATE_IDLE)
				return
			var tarPos:Vector3 = _thinkInfo.target.t.origin
			_look_toward_flat(tarPos)
			_subThinkTick -= _delta
			if _subThinkTick <= 0.0:
				_subThinkTick = 999
				_fire_gun()
		MOB_STATE_BLOCKING:
			if _thinkInfo.target == null:
				_change_state(MOB_STATE_IDLE)
				return
			var tarPos:Vector3 = _thinkInfo.target.t.origin
			_look_toward_flat(tarPos)

func _process(delta) -> void:
	super._process(delta)
