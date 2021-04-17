extends KinematicBody
class_name MobBase

signal on_mob_died(mob)

onready var _sprite:CustomAnimator3D = $sprite
onready var _body:CollisionShape = $body
onready var _attack = $attack
onready var _stats:MobStats = $stats
onready var _ent:Entity = $Entity

# const MOVE_SPEED:float = 4.5
const MOVE_TIME:float = 1.5
const LOS_CHECK_TIME:float = 0.25
const STUN_TIME:float = 0.2

export var delaySpawn:bool = false
export var triggerTargets:String = ""

enum MobState {
	Idle,
	Spawning,
	Hunting,
	Attacking,
	Stunned,
	# all corpse states below this point
	Dying,
	Dead,
	Gibbing,
	Gibbed
}

var _sourceId:int = 0

var _state = MobState.Idle
var _prevState = MobState.Idle

var _targetInfo: Dictionary = { id = 0 }

var _moveTick:float = 0
var _moveYaw:float = 0

var _thinkTick:float = 0

var _stunAccumulator:int = 0
var _stunDamageMax:int = 20

var _pushAccumulator:Vector3 = Vector3()

var _maxHealth:int = 50
var _health:int = 50
var _dead:bool = false

var _velocity:Vector3 = Vector3()

func _ready() -> void:
	_attack.custom_init($head, self)
	add_to_group(Groups.GAME_GROUP_NAME)
	var _r = _ent.connect("entity_restore_state", self, "restore_state")
	_r = _ent.connect("entity_append_state", self, "append_state")
	# move yaw is used for facing angle too so make sure it
	# matches spawn transform
	_moveYaw = rotation_degrees.y
	# var mobBasePath:String = self.filename
	# print("Mob base path: " + mobBasePath)

func set_source(node:Node, sourceId:int) -> void:
	_sourceId = sourceId
	var _r = connect("on_mob_died", node, "_on_mob_died")

func teleport(t:Transform) -> void:
	global_transform = t
	_moveYaw = rotation_degrees.y

func force_awake() -> void:
	if _state == MobState.Idle:
		_state = MobState.Hunting

func append_state(_dict:Dictionary) -> void:
	_dict.xform = ZqfUtils.transform_to_dict(global_transform)
	_dict.hp = _health
	_dict.state = _state
	_dict.prevState = _prevState
	_dict.yaw = _moveYaw
	_dict.tars = triggerTargets
	_dict.srcId = _sourceId

func restore_state(_dict:Dictionary) -> void:
	global_transform = ZqfUtils.transform_from_dict(_dict.xform)
	_change_state(_dict.state)
	_prevState = _dict.prevState
	_health = _dict.hp
	_moveYaw = _dict.yaw
	triggerTargets = _dict.tars

	# rewire to source
	var id:int = _dict.srcId
	if id == 0:
		return
	var node = Ents.find_static_entity_by_id(id)
	if node == null:
		print("Mob found no static ent " + str(id) + " to call on death")
		return
	set_source(node.get_root_node(), id)

func game_on_reset() -> void:
	queue_free()

func is_dead() -> bool:
	return (_state >= MobState.Dying)

func _change_state(_newState) -> void:
	if _state == _newState:
		return
	_prevState = _state
	_state = _newState
	_thinkTick = 0
	if _state == MobState.Hunting:
		_thinkTick = MOVE_TIME
		_sprite.play_animation("walk")
	elif _state == MobState.Attacking:
		_sprite.play_animation("aim")
	elif _state == MobState.Stunned:
		pass
	elif _state == MobState.Idle:
		pass
	elif _state == MobState.Spawning:
		pass
	elif _state == MobState.Dying:
		_sprite.play_animation("dying")
		# _body.disabled = true
		self.collision_layer = Interactions.CORPSE
		self.collision_mask = Interactions.CORPSE | Interactions.WORLD | Interactions.ACTOR_BARRIER
	elif _state == MobState.Dead:
		pass
	elif _state == MobState.Gibbing:
		_sprite.play_animation("dead_gib")
		_body.disabled = true
		_sprite.visible = false
	elif _state == MobState.Gibbed:
		_sprite.play_animation("dead_gib")
		_body.disabled = true
		_sprite.visible = false
		pass

func _calc_self_move(_delta:float) -> Vector3:
	# look_at(_curTarget.global_transform.origin, Vector3.UP)
	if _moveTick <= 0:
		# decide on next move
		_moveTick = 1
		var selfPos:Vector3 = global_transform.origin
		# var tarTrans:Transform = _curTarget.global_transform
		# var tarPos:Vector3 = tarTrans.origin
		var tarPos:Vector3 = _targetInfo.position
		var _tarYaw:float = _targetInfo.yawDegrees
		var dist:float = ZqfUtils.flat_distance_between(selfPos, tarPos)
		if dist > 15:
			_moveYaw = ZqfUtils.yaw_between(selfPos, tarPos)
		elif dist > 3:
			# var tarFacing:float = _calc_target_side(selfPos, tarPos, -tarTrans.basis.z)
			_moveYaw = ZqfUtils.yaw_between(selfPos, tarPos)
			
			# apply evasion from player aim direction
			# var leftOfTar:bool = ZqfUtils.is_point_left_of_line3D_flat(tarPos, _targetInfo.forward, selfPos)
			# if leftOfTar:
			# 	print("left at " + str(selfPos))
			# 	_moveYaw -= deg2rad(90)
			# else:
			# 	print("right at " + str(selfPos))
			# 	_moveYaw += deg2rad(90)
			
			# apply some random evasion - very jittery
			var quarter:float = deg2rad(90)
			_moveYaw -= quarter
			_moveYaw += rand_range(0, quarter * 2.0)
		else:
			_moveYaw = rand_range(0, PI * 2)
	else:
		_moveTick -= _delta
	
	rotation.y = _moveYaw
	var move:Vector3 = Vector3()
	move.x = -sin(_moveYaw)
	move.z = -cos(_moveYaw)
	move *= _stats.moveSpeed
	return move
	# return Vector3()

func move(_delta:float) -> void:
	var move:Vector3 = _calc_self_move(_delta)
	var _result = self.move_and_slide(move)

func _tick_stunned(_delta:float) -> void:
	if _thinkTick <= 0:
		_change_state(_prevState)
		return
	else:
		_thinkTick -= _delta
	_velocity = self.move_and_slide(_velocity)
	_velocity *= 0.95

func _process(_delta:float) -> void:
	if _state == MobState.Hunting:
		# var wasEmpty:bool = (_targetInfo.id == 0)
		_targetInfo = Game.mob_check_target(_targetInfo)
		# if _targetInfo.id != 0 && wasEmpty:
		# 	print("Mob got target!")
		# elif _targetInfo.id == 0 && !wasEmpty:
		# 	print("Mob lost target!")
		if _targetInfo.id == 0:
			return
		
		if _thinkTick <= 0:
			_thinkTick = MOVE_TIME
			if _attack.start_attack(_targetInfo.position):
				_change_state(MobState.Attacking)
		else:
			_thinkTick -= _delta
			move(_delta)
	elif _state == MobState.Attacking:
		_targetInfo = Game.mob_check_target(_targetInfo)
		if _targetInfo.id == 0:
			# abort attack!
			return
		
		rotation.y = ZqfUtils.yaw_between(global_transform.origin, _targetInfo.position)
		
		if !_attack.custom_update(_delta, _targetInfo.position):
			_change_state(MobState.Hunting)
	elif _state == MobState.Idle:
		if _thinkTick <= 0:
			_thinkTick = LOS_CHECK_TIME
			# if Game.check_player_in_front(global_transform.origin, _moveYaw):
			# 	if Game.check_los_to_player(global_transform.origin):
			# 		_change_state(MobState.Hunting)
			# 	else:
			# 		print("Player in front but cannot see!")
			if Game.check_los_to_player(global_transform.origin):
					_change_state(MobState.Hunting)
		else:
			_thinkTick -= _delta
		return
	elif _state == MobState.Spawning:
		return
	elif _state == MobState.Stunned:
		_tick_stunned(_delta)
		return
	elif _state == MobState.Dying:
		_velocity = self.move_and_slide(_velocity)
		_velocity *= 0.95
		return
	elif _state == MobState.Dead:
		return

func apply_stun(dir:Vector3) -> void:
	# stun
	if _state != MobState.Stunned:
		_change_state(MobState.Stunned)
	_attack.cancel()
	_velocity = dir * 2
	_thinkTick = STUN_TIME

func regular_death() -> void:
	_change_state(MobState.Dying)

func gib_death(dir:Vector3) -> void:
	Game.spawn_gibs(global_transform.origin, dir, 6)
	_change_state(MobState.Gibbed)

func corpse_hit(_hitInfo:HitInfo) -> int:
	print("Corpse hit - frame == " + str(_sprite.get_frame_number()))
	if _hitInfo.damageType == Interactions.DAMAGE_TYPE_EXPLOSIVE:
		var gibbable:bool = (_state == MobState.Dying || _state == MobState.Dead)
		if gibbable:
			gib_death(_hitInfo.direction)
		return 1
	elif _sprite.get_frame_number() <= 1:
		if _health < -_maxHealth * 1000:
			gib_death(_hitInfo.direction / 10)
		else:
			_health -= _hitInfo.damage
			_sprite.set_frame_number(0)
			_velocity += _hitInfo.direction * 3
		return 1
	else:
		return Interactions.HIT_RESPONSE_PENETRATE

func hit(_hitInfo:HitInfo) -> int:
	if is_dead():
		return corpse_hit(_hitInfo)
	_health -= _hitInfo.damage
	if _health <= 0:
		# die
		if _hitInfo.damageType == Interactions.DAMAGE_TYPE_EXPLOSIVE:
			gib_death(_hitInfo.direction)
		else:
			regular_death()
		emit_signal("on_mob_died", self)
		Interactions.triggerTargets(get_tree(), triggerTargets)
		return _hitInfo.damage + _health
	else:
		# if not awake, wake up!
		force_awake()
		apply_stun(_hitInfo.direction)
		return _hitInfo.damage
