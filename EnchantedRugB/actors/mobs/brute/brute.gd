extends CharacterBody3D
class_name Brute

var _popGfx = preload("res://gfx/mob_pop/mob_pop.tscn")

const ANIM_STOWED:String = "stowed"
const ANIM_IDLE:String = "idle"
const ANIM_BLOCK:String = "block"
const ANIM_SWING_1:String = "swing_1"
const ANIM_CHOP_1:String = "chop"

@onready var _swordArea:Area3D = $pods/right/sword_area
@onready var _swordShape:CollisionShape3D = $pods/right/sword_area/CollisionShape3D
@onready var _podsAnimator:AnimationPlayer = $pods/AnimationPlayer
@onready var _thinkTimer:Timer = $think_timer
@onready var _tarInfo:ActorTargetInfo = $actor_target_info

@onready var _agent:NavigationAgent3D = $NavigationAgent3D

#@onready var _hitBox:HitBox = $hitbox
var _swordHit:HitInfo

enum State { Idle, Charging, Approaching, Swinging, Dazed, Stunned }
var _state:State = State.Approaching

func _ready():
	_swordHit = Game.new_hit_info()
	_swordHit.teamId = Game.TEAM_ID_ENEMY
	#_hitBox.connect("health_depleted", _on_health_depleted)
	#_hitBox.teamId = Game.TEAM_ID_ENEMY
	_swordArea.connect("area_entered", _sword_touched_area)
	_thinkTimer.connect("timeout", _think_timeout)
	
	pass

func _animation_started(_animName:String) -> void:
	pass

func _animation_changed(_oldName:String, _newName:String) -> void:
	pass

func _animation_finished(_animName:String) -> void:
	pass

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

func hit(_hitInfo:HitInfo) -> int:
	if _hitInfo.teamId == Game.TEAM_ID_ENEMY:
		return -1
	print("Brute - took hit")
	Game.gfx_spawn_impact_sparks(_hitInfo.hitPosition)
	return 1

func _begin_approach(tarInfo:ActorTargetInfo) -> void:
	_state = State.Approaching
	_podsAnimator.play(ANIM_BLOCK)
	_agent.set_target_position(_tarInfo.position)
	_thinkTimer.wait_time = 0.25
	_thinkTimer.start()

func _think_timeout() -> void:
	if !Game.validate_target(_tarInfo):
		return
	var distSqr:float = global_position.distance_squared_to(_tarInfo.position)
	match _state:
		State.Approaching:
			_state = State.Swinging
			if distSqr > 6 * 6:
				_begin_approach(_tarInfo)
				#_podsAnimator.play(ANIM_BLOCK)
				#_agent.set_target_position(_tarInfo.position)
				#_thinkTimer.wait_time = 0.25
				#_thinkTimer.start()
				return
			_thinkTimer.wait_time = 1.5
			_thinkTimer.start()
			if randf() > 0.5:
				_podsAnimator.play(ANIM_SWING_1)
			else:
				_podsAnimator.play(ANIM_CHOP_1)
			pass
		State.Swinging:
			_begin_approach(_tarInfo)
			#_podsAnimator.play(ANIM_BLOCK)
			#_agent.set_target_position(_tarInfo.position)
			#_state = State.Approaching
			#_thinkTimer.wait_time = 0.25
			#_thinkTimer.start()

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
