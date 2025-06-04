extends CharacterBody3D
class_name MobBase

signal MobStateChange(newState, prevState, mobBase)

@onready var _thinkTimer:Timer = $think_timer
@onready var _tarInfo:ActorTargetInfo = $actor_target_info
@onready var _agent:NavigationAgent3D = $NavigationAgent3D
@onready var _knockBackArea:Area3D = $knockback_aoe
@onready var _knockBackShape:CollisionShape3D = $knockback_aoe/CollisionShape3D

@export var initialHealth:int = 500
@export var gfxType:HitBox.HitboxGFXType = HitBox.HitboxGFXType.Enemy
@export var attackDistance:float = 6.0
# if parry damage exceeds, stagger, or whatever...
@export var parryDamageLimit:float = 100.0
# if regular damage guarded exceeds this amount, do something... 
@export var guardRetaliationThreshold:float = 50.0
# if 'guard breaker' damage received exceeds, stagger, or something...
@export var guardDamageLimit:float = 50.0

var _swordHit:HitInfo

var _state:GameCtrl.MobState = GameCtrl.MobState.Idle

var _isGuarding:bool = false
var _attackIsActive:bool = false

var _lastKnockbackDir:Vector3 = Vector3()
var lastHit:HitInfo = null
var _teamId:int = 0

var _health:float = 50
var _guardDamage:int = 0.0
var _parryDamage:float = 0.0
var _parryRecoverRate:float = 5.0

var _lastHitId:String = ""
var _dead:bool = false;

var debugHits:bool = true

func _ready():
	_health = initialHealth
	_swordHit = Game.new_hit_info()
	_swordHit.teamId = Game.TEAM_ID_ENEMY
	_thinkTimer.connect("timeout", _think_timeout)
	_knockBackArea.monitoring = false
	_knockBackArea.connect("area_entered", _on_area_entered_knockback)
	_knockBackArea.connect("body_entered", _on_body_entered_knockback)
	#_knockBackShape.disabled = true
	ready_components()

func ready_components() -> void:
	pass

#######################################################
# incoming damage
#######################################################
func custom_hit(_incomingHit:HitInfo) -> void:
	pass

func hit(_incomingHit:HitInfo) -> int:
	if _incomingHit.attackId != "":
		if _incomingHit.attackId == _lastHitId:
			return Game.HIT_RESPONSE_IGNORED
		_lastHitId = _incomingHit.attackId
	if _incomingHit == null:
		return Game.HIT_RESPONSE_IGNORED
	if _dead:
		return Game.HIT_RESPONSE_IGNORED
	if _incomingHit.teamId == _teamId:
		return Game.HIT_RESPONSE_WHIFF
	
	var guardDamage:float = _incomingHit.damage
	if _incomingHit.guardDamage >= 0:
		guardDamage = _incomingHit.guardDamage
	var parryDamage:float = _incomingHit.damage
	if _incomingHit.parryDamage >= 0:
		parryDamage = _incomingHit.parryDamage
	
	if _state == GameCtrl.MobState.StaticGuard:
		# guard breaker?
		if guardDamage > 0:
			_guardDamage += _incomingHit.guardDamage
			if _guardDamage > guardDamageLimit:
				_guardDamage = 0.0
				_begin_parried(_tarInfo)
			return _incomingHit.damage
		
		# projectiles automatically whiff._active
		# maybe reflect them later
		if _incomingHit.category == Game.DAMAGE_CATEGORY_PROJECTILE:
			_begin_static_guard(_tarInfo)
			return Game.HIT_RESPONSE_WHIFF

		# TODO: Guard crush damage type...
		# parry attack and roll for an immediate attempt to punish
		if randf() > 0.5:
			_begin_static_guard(_tarInfo)
		else:
			_begin_random_swing(_tarInfo)
		return Game.HIT_RESPONSE_PARRIED
	
	_health -= _incomingHit.damage
	_incomingHit.lastInflicted = _incomingHit.damage
	lastHit = _incomingHit
	Game.gfx_spawn_impact_sparks(_incomingHit.hitPosition)
	
	custom_hit(_incomingHit)

	if _health <= 0:
		die()
		return _incomingHit.damage
	
	if _state == GameCtrl.MobState.Juggled:
		if _incomingHit.flags & HitInfo.FLAG_VERTICAL_LAUNCHER != 0:
			_begin_juggled(_tarInfo)
			return _incomingHit.damage
		if _incomingHit.flags & HitInfo.FLAG_HORIZONTAL_LAUNCHER != 0:
			_begin_launched(_incomingHit.direction)
			return _incomingHit.damage
		if self.velocity.y < 2:
			self.velocity = Vector3(0, 2, 0)
		return _incomingHit.damage
	
	if _state == GameCtrl.MobState.Launched:
		if _incomingHit.flags & HitInfo.FLAG_VERTICAL_LAUNCHER != 0:
			_begin_juggled(_tarInfo)
			return _incomingHit.damage
		return _incomingHit.damage

	if _state == GameCtrl.MobState.Staggered || _state == GameCtrl.MobState.Parried:
		if _incomingHit.flags & HitInfo.FLAG_VERTICAL_LAUNCHER != 0:
			_begin_juggled(_tarInfo)
			return _incomingHit.damage
		if _incomingHit.flags & HitInfo.FLAG_HORIZONTAL_LAUNCHER != 0:
			_begin_launched(_incomingHit.direction)
			return _incomingHit.damage
	if _state == GameCtrl.MobState.Staggered || _state == GameCtrl.MobState.Parried:
		return _incomingHit.damage

	if _state == GameCtrl.MobState.Swinging:
		# attack is interupted based on parry damage taken...
		# grab current attack setting as the state change will reset the attack flag
		var wasAttacking:bool = _attackIsActive
		_parryDamage += 50
		if _parryDamage < parryDamageLimit:
			_begin_parried(_tarInfo)
		else:
			_parryDamage = 0.0
			_begin_stagger(_tarInfo)
		
		# ...however, if our damage was not active, it is not a true counter hit
		#if _swordArea.get_blade_state() != MobMeleeWeapon.BladeState.Damaging:
		#if !wasAttacking:
		#	return Game.HIT_RESPONSE_PARRIED
		#else:
		#	return _incomingHit.damage
		
		return _incomingHit.damage

	_begin_stagger(_tarInfo)
	return _incomingHit.damage

func get_health_percentage() -> float:
	return (float(_health) / float(initialHealth)) * 100.0

func receive_grab(_grabber) -> Node3D:
	return null

func die() -> void:
	_dead = true
	self.queue_free()

#######################################################
# mob effects
#######################################################

func _on_area_entered_knockback(_area:Area3D) -> void:
	if _area.has_method("receive_aoe_knockback"):
		_area.receive_aoe_knockback(_lastKnockbackDir)
	pass

func _on_body_entered_knockback(body) -> void:
	print("Body entered")
	if body.has_method("receive_aoe_knockback"):
		body.receive_aoe_knockback(_lastKnockbackDir)
	pass

func receive_aoe_knockback(_direction:Vector3) -> void:
	if _state != GameCtrl.MobState.Launched:
		_begin_launched(_direction)

#######################################################
#######################################################
# state
#######################################################
#######################################################

func launch() -> void:
	$CollisionShape3D.disabled = false
	$hitbox/CollisionShape3D.disabled = false
	pass

func look_at_flat(targetPos:Vector3) -> void:
	targetPos.y = self.global_position.y
	ZqfUtils.look_at_safe(self, targetPos)
	pass

# returns previous state in case you need to compare them after
# changing state
func _set_state(_newState) -> GameCtrl.MobState:
	#if _newState != _state:
	#	var from:String = GameCtrl.MobState.keys()[_state]
	#	var to:String = GameCtrl.MobState.keys()[_newState]
	#	print("Mob state from " + from + " to " + to)
	var prevState:GameCtrl.MobState = _state
	_state = _newState
	_knockBackArea.monitoring = (_state == GameCtrl.MobState.Launched)
	#_knockBackShape.disabled = !(_state == GameCtrl.MobState.Launched)
	#print("Knockback enabled " + str(_knockB))
	#_knockBackArea.monitoring = (_state == GameCtrl.MobState.Launched)

	self.emit_signal("MobStateChange", _state, prevState, self)
	return prevState

#######################################################
# begin
#######################################################
func _begin_idle() -> void:
	_set_state(GameCtrl.MobState.Idle)
	_thinkTimer.wait_time = 0.5
	_thinkTimer.start()
	_attackIsActive = false
	_isGuarding = false

func _begin_approach(__tarInfo:ActorTargetInfo) -> void:
	_set_state(GameCtrl.MobState.Approaching)
	_agent.set_target_position(__tarInfo.position)
	_thinkTimer.wait_time = 0.25
	_thinkTimer.start()
	_attackIsActive = false

func _begin_static_guard(__tarInfo:ActorTargetInfo) -> void:
	_set_state(GameCtrl.MobState.StaticGuard)
	_thinkTimer.paused = false
	_thinkTimer.start(1.0)
	_isGuarding = true
	_attackIsActive = false

func _begin_random_swing(__tarInfo:ActorTargetInfo) -> void:
	_set_state(GameCtrl.MobState.Swinging)
	_thinkTimer.start(2)

func _set_to_swinging() -> void:
	look_at_flat(_tarInfo.position)
	_isGuarding = false
	_attackIsActive = false
	_set_state(GameCtrl.MobState.Swinging)
	_thinkTimer.paused = false
	_thinkTimer.start(3)

func _end_swing() -> void:
	_begin_approach(_tarInfo)

func _begin_stagger(__tarInfo:ActorTargetInfo) -> void:
	_isGuarding = false
	_attackIsActive = false
	_set_state(GameCtrl.MobState.Staggered)
	_thinkTimer.paused = false
	_thinkTimer.start(4)
	pass

func _begin_parried(__tarInfo:ActorTargetInfo) -> void:
	_isGuarding = false
	_attackIsActive = false
	_set_state(GameCtrl.MobState.Parried)
	_thinkTimer.paused = false
	_thinkTimer.start(1.5)

func _begin_juggled(__tarInfo:ActorTargetInfo) -> void:
	_isGuarding = false
	_attackIsActive = false
	_set_state(GameCtrl.MobState.Juggled)
	_thinkTimer.stop()
	#_thinkTimer.wait_time = 1.5
	#_thinkTimer.start()
	self.velocity = Vector3(0, 10, 0)

func _begin_launched(atkDirection:Vector3) -> void:
	_lastKnockbackDir = atkDirection
	_isGuarding = false
	_attackIsActive = false
	_set_state(GameCtrl.MobState.Launched)
	_thinkTimer.paused = false
	_thinkTimer.start(2)
	# move up *slightly* to avoid immediately clipping the ground
	self.global_position.y += 0.1
	var vel:Vector3 = atkDirection * 25.0
	vel.y = 2.0
	self.velocity = vel

#######################################################
# tock
#######################################################
func _tock_idle() -> void:
	_begin_approach(_tarInfo)

func _tock_approaching() -> void:
	var distSqr:float = global_position.distance_squared_to(_tarInfo.position)
	if distSqr > attackDistance * attackDistance:
		_begin_approach(_tarInfo)
		return
	_begin_random_swing(_tarInfo)

func _tock_static_guard() -> void:
	var distSqr:float = global_position.distance_squared_to(_tarInfo.position)
	if distSqr > attackDistance * attackDistance:
		_begin_approach(_tarInfo)
	elif randf() > 0.75:
		_begin_static_guard(_tarInfo)
	else:
		_begin_random_swing(_tarInfo)

func _tock_swinging() -> void:
	_begin_approach(_tarInfo)

func _tock_staggered() -> void:
	_begin_static_guard(_tarInfo)

func _tock_parried() -> void:
	_begin_static_guard(_tarInfo)

func _tock_launched() -> void:
	_begin_idle()

func _think_timeout() -> void:
	if !Game.validate_target(_tarInfo):
		return
	match _state:
		GameCtrl.MobState.Idle:
			_tock_idle()
		GameCtrl.MobState.Approaching:
			_tock_approaching()
		GameCtrl.MobState.StaticGuard:
			_tock_static_guard()
		GameCtrl.MobState.Swinging:
			_tock_swinging()
		GameCtrl.MobState.Staggered:
			_tock_staggered()
		GameCtrl.MobState.Parried:
			_tock_parried()
		GameCtrl.MobState.Launched:
			_tock_launched()

	look_at_flat(_tarInfo.position)

#######################################################
# tick
#######################################################
func _tick_approaching(_delta:float) -> void:
	look_at_flat(_tarInfo.position)
	if _agent.physics_tick(_delta):
		self.velocity = _agent.velocity
		move_and_slide()
		#print("MobBase vel " + str(self.velocity.length()))

func _tick_static_guard(_delta:float) -> void:
	look_at_flat(_tarInfo.position)

func _tick_swinging(_delta:float) -> void:
	pass

func _tick_launched(_delta:float) -> void:
	self.move_and_slide()
	var vel:Vector3 = self.velocity
	vel.x *= 0.99
	vel.z *= 0.99
	vel.y -= 20.0 * _delta
	self.velocity = vel

func _physics_process(_delta:float) -> void:
	if _parryDamage > 0.0:
		_parryDamage -= _parryRecoverRate * _delta
	
	if _state == GameCtrl.MobState.Juggled:
		self.velocity += Vector3(0, -10, 0) * _delta
		self.move_and_slide()
		if self.is_on_floor() && !self.velocity.y > 0.0:
			_begin_stagger(_tarInfo)
		return
	
	# validate target here just to get up-to-date info
	if !Game.validate_target(_tarInfo): # && _state != GameCtrl.MobState.StaticGuard:
		_begin_idle()
	match _state:
		GameCtrl.MobState.Swinging:
			_tick_swinging(_delta)
		GameCtrl.MobState.Approaching:
			_tick_approaching(_delta)
		GameCtrl.MobState.StaticGuard:
			_tick_static_guard(_delta)
		GameCtrl.MobState.Launched:
			_tick_launched(_delta)
