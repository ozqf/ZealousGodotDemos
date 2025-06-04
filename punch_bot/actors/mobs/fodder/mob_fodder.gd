extends MobBase
class_name MobFodder

@onready var _swordArea:MobMeleeWeapon = $pods/right/sword_area
@onready var _podsAnimator:ZqfAnimationKeyEmitter = $pods/AnimationPlayer

@onready var _hitJitter:ModelHitJitter = $display/display_animator

func ready_components() -> void:
	_swordArea.connect("area_entered", _sword_touched_area)
	_swordArea.set_blade_state(MobMeleeWeapon.BladeState.Idle)
	#_podsAnimator.connect("animation_started", _animation_started)
	#_podsAnimator.connect("animation_changed", _animation_changed)
	#_podsAnimator.connect("animation_finished", _animation_finished)
	_podsAnimator.connect("anim_key_event", _on_anim_key_event)

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

func custom_hit(_incomingHit:HitInfo) -> void:
	_hitJitter.runHitKnockback(_incomingHit.direction)

func hit(_incomingHit:HitInfo) -> int:
	if _incomingHit == null:
			return Game.HIT_RESPONSE_IGNORED
	if _dead:
		return Game.HIT_RESPONSE_IGNORED
	if _incomingHit.teamId == _teamId:
		return Game.HIT_RESPONSE_WHIFF
	
	_health -= _incomingHit.damage
	_incomingHit.lastInflicted = _incomingHit.damage
	lastHit = _incomingHit
	Game.gfx_spawn_impact_sparks(_incomingHit.hitPosition)
	
	custom_hit(_incomingHit)

	if _health <= 0:
		die()
		return _incomingHit.damage
	
	#_begin_stagger(_tarInfo)
	match _state:
		GameCtrl.MobState.Juggled:
			pass
		GameCtrl.MobState.Launched:
			pass
		GameCtrl.MobState.Staggered:
			pass
		GameCtrl.MobState.Parried:
			if _incomingHit.flags & HitInfo.FLAG_VERTICAL_LAUNCHER != 0:
				_begin_juggled(_tarInfo)
			elif _incomingHit.flags & HitInfo.FLAG_HORIZONTAL_LAUNCHER != 0:
				_begin_launched(_incomingHit.direction)
		_:
			_begin_parried(_tarInfo)
	return _incomingHit.damage


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

func _begin_random_swing(__tarInfo:ActorTargetInfo) -> void:
	#super(__tarInfo)
	_set_to_swinging()
	_podsAnimator.play("drunk_punch")

func _begin_parried(__tarInfo:ActorTargetInfo) -> void:
	super(__tarInfo)
	_podsAnimator.play("parried")

func _begin_stagger(__tarInfo:ActorTargetInfo) -> void:
	super(__tarInfo)
	_podsAnimator.play("staggered")
	pass
