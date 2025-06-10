extends MobBase
class_name Brute

var _popGfx = preload("res://gfx/mob_pop/mob_pop.tscn")
var _corpseType = preload("res://actors/mobs/brute/brute_corpse.tscn")

const ANIM_STOWED:String = "stowed"
const ANIM_IDLE:String = "idle"
const ANIM_BLOCK:String = "block"
const ANIM_SWING_1:String = "swing_1"
const ANIM_SWING_2:String = "swing_2"
const ANIM_CHOP_1:String = "chop"
const ANIM_STAGGERED:String = "staggered"
const ANIM_PARRIED:String = "parried"

@onready var _swordArea:MobMeleeWeapon = $pods/right/sword_area
@onready var _podsAnimator:ZqfAnimationKeyEmitter = $pods/AnimationPlayer

func ready_components() -> void:
	_swordArea.connect("area_entered", _sword_touched_area)
	_swordArea.set_blade_state(MobMeleeWeapon.BladeState.Idle)
	_podsAnimator.connect("animation_started", _animation_started)
	_podsAnimator.connect("animation_changed", _animation_changed)
	_podsAnimator.connect("animation_finished", _animation_finished)
	_podsAnimator.connect("anim_key_event", _on_anim_key_event)

#######################################################
# animation callbacks
#######################################################
func _animation_started(_animName:String) -> void:
	#print("Brute anim start " + _animName)
	match _animName:
		ANIM_SWING_1:
			_swordArea.set_blade_state(MobMeleeWeapon.BladeState.Idle)
		ANIM_SWING_2:
			_swordArea.set_blade_state(MobMeleeWeapon.BladeState.Idle)
		ANIM_CHOP_1:
			_swordArea.set_blade_state(MobMeleeWeapon.BladeState.Idle)
		ANIM_STAGGERED:
			_swordArea.set_blade_state(MobMeleeWeapon.BladeState.Off)
		ANIM_PARRIED:
			_swordArea.set_blade_state(MobMeleeWeapon.BladeState.Idle)
		ANIM_BLOCK:
			_swordArea.set_blade_state(MobMeleeWeapon.BladeState.Blocking)

func _animation_changed(_oldName:String, _newName:String) -> void:
	#print("Brute anim changed from " + _oldName + " to " + _newName)
	pass

func _animation_finished(_animName:String) -> void:
	#print("Brute anim finished " + _animName)
	match _animName:
		ANIM_SWING_1:
			_swordArea.set_blade_state(MobMeleeWeapon.BladeState.Idle)
			_end_swing()
		ANIM_SWING_2:
			_swordArea.set_blade_state(MobMeleeWeapon.BladeState.Idle)
			_end_swing()
		ANIM_CHOP_1:
			_swordArea.set_blade_state(MobMeleeWeapon.BladeState.Idle)
			_end_swing()
		ANIM_PARRIED:
			_swordArea.set_blade_state(MobMeleeWeapon.BladeState.Idle)
			_begin_static_guard(_tarInfo)
			#_try_begin_random_swing(_tarInfo)

func _on_anim_key_event(__animName:String, __keyIndex:int) -> void:
	match __keyIndex:
		0:
			_attackIsActive = true
			#_isGuarding = false
			_swordArea.set_blade_state(MobMeleeWeapon.BladeState.Damaging)
		1:
			_attackIsActive = false
			#_isGuarding = true
			_swordArea.set_blade_state(MobMeleeWeapon.BladeState.Idle)

func die() -> void:
	super()
	var gfx = _popGfx.instantiate()
	Zqf.get_actor_root().add_child(gfx)
	gfx.global_transform = self.global_transform

	var corpse:RigidBody3D = _corpseType.instantiate() as RigidBody3D
	Zqf.get_actor_root().add_child(corpse)
	corpse.global_transform = self.global_transform
	
	var lv:Vector3 = Vector3()
	lv.x = randf_range(1, 3)
	lv.y = randf_range(1, 5)
	lv.z = randf_range(1, 3)
	corpse.linear_velocity = lv

	var av:Vector3 = Vector3()
	av.x = randf_range(-40, 40)
	av.y = randf_range(-40, 40)
	#av.z = randf_range(-100, 100)
	corpse.angular_velocity = av

#######################################################
# sword control
#######################################################

func _sword_touched_area(_area:Area3D) -> void:
	if _area.has_method("hit"):
		_swordHit.hitPosition = _swordArea.global_position
		var result = _area.hit(_swordHit)
		if result > 0:
			print("Brute swing landed")
	pass

#######################################################
# state
#######################################################
func _begin_approach(__tarInfo:ActorTargetInfo) -> void:
	super(__tarInfo)
	_isGuarding = true
	_podsAnimator.play(ANIM_BLOCK)

func _begin_static_guard(__tarInfo:ActorTargetInfo) -> void:
	super(__tarInfo)
	_podsAnimator.play(ANIM_BLOCK)

func _try_begin_random_swing(__tarInfo:ActorTargetInfo) -> bool:
	#super(__tarInfo)
	var flatDistSqr:float = ZqfUtils.flat_distance_sqr(self.global_position, __tarInfo.position)
	var swing1Range:float = 6.0
	var swing2Range:float = 4.0
	var r:float = randf()
	if flatDistSqr > (swing1Range * swing1Range):
		return false
	
	_set_to_swinging()
	if flatDistSqr > (swing2Range * swing2Range):
		if r > 0.5:
			_podsAnimator.play(ANIM_CHOP_1)
		else:
			_podsAnimator.play(ANIM_SWING_1)
		return true
	
	if r > 0.66:
		_podsAnimator.play(ANIM_SWING_1)
	elif r > 0.33:
		_podsAnimator.play(ANIM_SWING_2)
	else:
		_podsAnimator.play(ANIM_CHOP_1)
	return true

func _begin_stagger(__tarInfo:ActorTargetInfo) -> void:
	super(__tarInfo)
	_podsAnimator.play(ANIM_STAGGERED)
	pass

func _begin_parried(__tarInfo:ActorTargetInfo) -> void:
	super(__tarInfo)
	_podsAnimator.play(ANIM_PARRIED)

func _begin_juggled(__tarInfo:ActorTargetInfo) -> void:
	super(__tarInfo)
	_podsAnimator.play(ANIM_STAGGERED)

func _begin_launched(atkDirection:Vector3) -> void:
	super(atkDirection)
	_podsAnimator.play(ANIM_STAGGERED)

func _tock_approaching() -> void:
	if !_try_begin_random_swing(_tarInfo):
		_begin_approach(_tarInfo)
		return

func _tock_approaching_old() -> void:
	var distSqr:float = global_position.distance_squared_to(_tarInfo.position)
	if distSqr > attackDistance * attackDistance:
		_begin_approach(_tarInfo)
		return
	if randf() > 0.75:
		_try_begin_random_swing(_tarInfo)
	else:
		_begin_static_guard(_tarInfo)

func _tick_swinging(_delta:float) -> void:
	if _podsAnimator.current_animation == ANIM_CHOP_1:
		if _podsAnimator.current_animation_position < 0.4:
			look_at_flat(_tarInfo.position)
