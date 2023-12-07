extends CharacterBody3D
class_name Brute

var _popGfx = preload("res://gfx/mob_pop/mob_pop.tscn")

var _matBladeOffMat = preload("res://shared/object_materials/laser_sword_off.tres")
var _matBladeOrange = preload("res://shared/object_materials/laser_sword_orange.tres")
var _matBladeRed = preload("res://shared/object_materials/laser_sword_red.tres")

const ANIM_STOWED:String = "stowed"
const ANIM_IDLE:String = "idle"
const ANIM_BLOCK:String = "block"
const ANIM_SWING_1:String = "swing_1"
const ANIM_SWING_2:String = "swing_2"
const ANIM_CHOP_1:String = "chop"
const ANIM_STAGGERED:String = "staggered"

@onready var _swordArea:Area3D = $pods/right/sword_area
@onready var _swordShape:CollisionShape3D = $pods/right/sword_area/CollisionShape3D
@onready var _podsAnimator:ZqfAnimationKeyEmitter = $pods/AnimationPlayer
@onready var _thinkTimer:Timer = $think_timer
@onready var _tarInfo:ActorTargetInfo = $actor_target_info

@onready var _bladeMesh:MeshInstance3D = $pods/right/blade
@onready var _agent:NavigationAgent3D = $NavigationAgent3D
@onready var _hitBox:HitBox = $hitbox

var _swordHit:HitInfo

enum State { Approaching, Swinging, StaticGuard, Staggered }
var _state:State = State.Approaching

enum BladeState { Idle, Damaging, Blocking, Off }
var _bladeState:BladeState = BladeState.Idle

func _ready():
	_swordHit = Game.new_hit_info()
	_swordHit.teamId = Game.TEAM_ID_ENEMY
	#_hitBox.connect("health_depleted", _on_health_depleted)
	_hitBox.teamId = Game.TEAM_ID_ENEMY
	_swordArea.connect("area_entered", _sword_touched_area)
	_thinkTimer.connect("timeout", _think_timeout)
	_swordShape.disabled = true
	_podsAnimator.connect("animation_started", _animation_started)
	_podsAnimator.connect("animation_changed", _animation_changed)
	_podsAnimator.connect("animation_finished", _animation_finished)
	_podsAnimator.connect("anim_key_event", _on_anim_key_event)
	_hitBox.connect("hitbox_event", _on_hitbox_event)

#######################################################
# animation callbacks
#######################################################
func _animation_started(_animName:String) -> void:
	print("Brute anim start " + _animName)
	match _animName:
		ANIM_SWING_1:
			set_blade_state(BladeState.Idle)
		ANIM_SWING_2:
			set_blade_state(BladeState.Idle)
		ANIM_CHOP_1:
			set_blade_state(BladeState.Idle)
		ANIM_STAGGERED:
			set_blade_state(BladeState.Off)
		ANIM_BLOCK:
			set_blade_state(BladeState.Blocking)

func _animation_changed(_oldName:String, _newName:String) -> void:
	
	print("Brute anim changed from " + _oldName + " to " + _newName)

func _animation_finished(_animName:String) -> void:
	print("Brute anim finished " + _animName)
	match _animName:
		ANIM_SWING_1:
			set_blade_state(BladeState.Idle)
			_end_swing()
		ANIM_SWING_2:
			set_blade_state(BladeState.Idle)
			_end_swing()
		ANIM_CHOP_1:
			set_blade_state(BladeState.Idle)
			_end_swing()

func _on_anim_key_event(keyIndex:int) -> void:
	match keyIndex:
		0:
			_hitBox.isGuarding = false
			set_blade_state(BladeState.Damaging)
		1:
			_hitBox.isGuarding = true
			set_blade_state(BladeState.Idle)

#######################################################
# sword control
#######################################################
func set_blade_state(newBladeState:BladeState) -> void:
	_bladeState = newBladeState
	match _bladeState:
		BladeState.Idle:
			_bladeMesh.material_override = _matBladeOrange
			_swordShape.disabled = true
		BladeState.Damaging:
			_bladeMesh.material_override = _matBladeRed
			_swordShape.disabled = false
		BladeState.Off:
			_bladeMesh.material_override = _matBladeOffMat
			_swordShape.disabled = true
		BladeState.Blocking:
			_bladeMesh.material_override = _matBladeOrange
			_swordShape.disabled = true

func _sword_touched_area(_area:Area3D) -> void:
	if _area.has_method("hit"):
		_swordHit.hitPosition = _swordArea.global_position
		var result = _area.hit(_swordHit)
		if result > 0:
			print("Brute swing landed")
	pass

func _on_health_depleted() -> void:
	var gfx = _popGfx.instantiate()
	Zqf.get_actor_root().add_child(gfx)
	gfx.global_transform = self.global_transform

func _on_hitbox_event(_eventType, __hitbox) -> void:
	match _eventType:
		HitBox.HITBOX_EVENT_DAMAGED:
			_begin_stagger(_tarInfo)
		HitBox.HITBOX_EVENT_GUARD_DAMAGED:
			_begin_static_guard(_tarInfo)

func hit(_hitInfo:HitInfo) -> int:
	if _hitInfo.teamId == Game.TEAM_ID_ENEMY:
		return -1
	print("Brute - took hit")
	Game.gfx_spawn_impact_sparks(_hitInfo.hitPosition)
	return 1

func _begin_approach(__tarInfo:ActorTargetInfo) -> void:
	_state = State.Approaching
	_podsAnimator.play(ANIM_BLOCK)
	_agent.set_target_position(__tarInfo.position)
	_thinkTimer.wait_time = 0.25
	_thinkTimer.start()
	_hitBox.isGuarding = true

func _begin_static_guard(__tarInfo:ActorTargetInfo) -> void:
	print("Begin static guard")
	_podsAnimator.play(ANIM_BLOCK)
	_state = State.StaticGuard
	_thinkTimer.wait_time = 1.0
	_thinkTimer.start()
	_hitBox.isGuarding = true

func _begin_random_swing(__tarInfo:ActorTargetInfo) -> void:
	_state = State.Swinging
	_thinkTimer.wait_time = 3
	_thinkTimer.start()
	if randf() > 0.66:
		_podsAnimator.play(ANIM_SWING_1)
	elif randf() > 0.33:
		_podsAnimator.play(ANIM_SWING_2)
	else:
		_podsAnimator.play(ANIM_CHOP_1)

func _end_swing() -> void:
	_begin_approach(_tarInfo)

func _begin_stagger(__tarInfo:ActorTargetInfo) -> void:
	_hitBox.isGuarding = false
	_state = State.Staggered
	_thinkTimer.wait_time = 0.5
	_thinkTimer.start()
	_podsAnimator.play(ANIM_STAGGERED)
	pass

func _think_timeout() -> void:
	if !Game.validate_target(_tarInfo):
		return
	var distSqr:float = global_position.distance_squared_to(_tarInfo.position)
	match _state:
		State.Approaching:
			if distSqr > 6 * 6:
				_begin_approach(_tarInfo)
				return
			if randf() > 0.75:
				_begin_random_swing(_tarInfo)
			else:
				_begin_static_guard(_tarInfo)
			pass
		State.StaticGuard:
			print("Static guard timeout")
			if distSqr > 6 * 6:
				_begin_approach(_tarInfo)
			elif randf() < 0.5:
				_begin_static_guard(_tarInfo)
			else:
				_begin_random_swing(_tarInfo)
		State.Swinging:
			_begin_approach(_tarInfo)
		State.Staggered:
			_begin_static_guard(_tarInfo)

	look_at_flat(_tarInfo.position)

func look_at_flat(targetPos:Vector3) -> void:
	targetPos.y = self.global_position.y
	ZqfUtils.look_at_safe(self, targetPos)
	pass

func _physics_process(_delta:float) -> void:
	match _state:
		State.Approaching:
			if _agent.physics_tick(_delta):
				self.velocity = _agent.velocity
				move_and_slide()
		State.StaticGuard:
			look_at_flat(_tarInfo.position)
