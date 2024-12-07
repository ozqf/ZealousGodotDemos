extends MobBase

const MOB_STATE_IDLE:String = "idle"
const MOB_STATE_STUNNED:String = "stunned"
const MOB_STATE_PARRIED:String = "parried"
const MOB_STATE_CHASE:String = "chase"
const MOB_STATE_ATTACK_MELEE:String = "attack_melee"
const MOB_STATE_ATTACK_RANGED:String = "attack_ranged"
const MOB_STATE_BLOCKING:String = "blocking"

const ANIM_IDLE:String = "_idle"
const ANIM_SWING_1:String = "swing_1"
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
var _bladeOn:bool = false

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

func _on_weapon_touched_area(area:Area3D) -> void:
	var result:int = Game.try_hit(_hitInfo, area)
	if result == Game.HIT_RESPONSE_PARRIED:
		_pushedDir = _bodyDisplayRoot.global_transform.basis.z
		on_parried(_hitInfo.responseParryWeight, _hitInfo.responseParryBaseStrength)
		return
	print("Mob response " + str(result))

func _change_state(newState:String) -> void:
	if _state == newState:
		return
	var oldState:String = _state
	_state = newState
	_meleeIndicator.off()
	_rangedIndicator.off()

	if _state != MOB_STATE_STUNNED:
		_defenceless = false
	match _state:
		MOB_STATE_CHASE:
			_thinkTime = 0.5
		MOB_STATE_STUNNED:
			_animator.play("stunned")
		MOB_STATE_PARRIED:
			_defenceless = true
			_meleeIndicator.off()
			_set_blade_on(false)
			_animator.play("stunned")
	_thinkTick = 0.0

func on_parried(weight:float, rootParryStrength:float = 1.0) -> void:
	print("Mob was parried!")
	_defenceStrength -= rootParryStrength * weight
	if _defenceStrength <= 0.0:
		_defenceStrength = _defenceStrengthMax
		_change_state(MOB_STATE_PARRIED)
		_thinkTime = 2.0
		Game.gfx_parry_impact(self._weapon.global_position)
	else:
		_change_state(MOB_STATE_PARRIED)
		_thinkTime = 0.5

func spawn() -> void:
	_healthMax = 20.0
	_defenceStrengthMax = 2.0
	_hitBounceTime = 1.0
	super.spawn()

func hit(_incomingHit:HitInfo) -> int:
	var type:int = _incomingHit.damageType
	match type:
		Game.DAMAGE_TYPE_PUNCH:
			if _bladeOn:
				on_parried(0.5, 1.0)
				pass
		Game.DAMAGE_TYPE_SLASH:
			if _bladeOn:
				on_parried(0.5, 1.0)
				pass
		Game.DAMAGE_TYPE_BULLET:
			if _bladeOn:
				on_parried(0.5, 1.0)
				pass
	var result:int = super.hit(_incomingHit)
	if _health <= 0.0:
		self.queue_free()
		return 1
	if result > 0:
		_change_state(MOB_STATE_STUNNED)
		_thinkTime = _hitBounceTime
	return result

func _think() -> void:
	match _state:
		#MOB_STATE_CHASE:
		#	_begin_melee_attack()
		MOB_STATE_STUNNED:
			_begin_block()
			pass
		_:
			var plyr:TargetInfo = Game.get_player_target()
			if plyr != null:
				_change_state(MOB_STATE_CHASE)
			else:
				_change_state(MOB_STATE_IDLE)

func _begin_melee_attack() -> void:
	_change_state(MOB_STATE_ATTACK_MELEE)
	_meleeIndicator.run(0.8)
	_animator.play(ANIM_SWING_1)
	_thinkTime = _animator.current_animation_length

func _begin_ranged_attack() -> void:
	_change_state(MOB_STATE_ATTACK_RANGED)
	_subThinkTick = 0.5
	_rangedIndicator.run(_subThinkTick)
	_animator.play(ANIM_SHOOTING)
	_thinkTime = _animator.current_animation_length

func _begin_block() -> void:
	_animator.play("_idle")
	_change_state(MOB_STATE_CHASE)

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
			var tarPos:Vector3 = _thinkInfo.target.t.origin
			_look_toward_flat(tarPos)
			var distSqr:float = _thinkInfo.xzTowardTarget.length_squared()
			var runDist:float = 7.0
			var stopDist:float = 2.0
			if distSqr > (runDist * runDist):
				_step_toward_flat(tarPos, 8.0, _delta)
				if _thinkInfo.target.inAction || !_enemyViewDetector.has_overlapping_areas():
					_begin_ranged_attack()
			elif distSqr > (stopDist * stopDist):
				_step_toward_flat(tarPos, 2.0, _delta)
				if _thinkInfo.target.inAction:
					_begin_ranged_attack()
			else:
				_begin_melee_attack()
		MOB_STATE_PARRIED:
			var weight:float = 1.0 - (_thinkTick / _thinkTime)
			_slide_in_direction(_pushedDir, 5 * weight, _delta)
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

func _process(delta) -> void:
	super._process(delta)
