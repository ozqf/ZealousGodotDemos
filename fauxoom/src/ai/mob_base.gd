extends KinematicBody
# AITicker wants to reference mobbase class but as it is a child of mob base
# we get a circular dependency
# waiting for Godot 4 to fix this apparently...
# https://www.reddit.com/r/godot/comments/hu213d/class_was_found_in_global_scope_but_its_script/
# class_name MobBase

const STUN_TIME:float = 0.2

signal on_mob_died(mob)
signal mob_event(tag)

onready var sprite:CustomAnimator3D = $sprite
onready var collisionShape:CollisionShape = $body
onready var head:Spatial = $head
onready var motor:MobMotor = $motor
onready var attack:MobAttack = $attack
onready var _stats:MobStats = $stats
onready var _ent:Entity = $Entity
onready var _ticker:AITicker = $ticker

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

# this dictionary is initialised locally as empty
# here but at runtime will be an external copy shared
# by other AI, so consider it read only!
# var _targetInfo: Dictionary = { id = 0 }

var _tickInfo:Dictionary = {
	id = 0,
	trueDistance = 0,
	flatDistance = 0
}

var _moveTick:float = 0
var _moveYaw:float = 0

var _thinkTick:float = 0

var _stunAccumulator:int = 0
var _pushAccumulator:Vector3 = Vector3()

var _health:int = 50
var _dead:bool = false

# var velocity:Vector3 = Vector3()

func _ready() -> void:
	attack.custom_init($head, self)
	motor.custom_init(self)
	_ticker.custom_init(self)
	add_to_group(Groups.GAME_GROUP_NAME)
	var _r = _ent.connect("entity_restore_state", self, "restore_state")
	_r = _ent.connect("entity_append_state", self, "append_state")
	# move yaw is used for facing angle too so make sure it
	# matches spawn transform
	_moveYaw = rotation_degrees.y
	sprite.set_yaw_override(head)
	_health = _stats.health

func set_source(node:Node, sourceId:int) -> void:
	_sourceId = sourceId
	var _r = connect("on_mob_died", node, "_on_mob_died")

func teleport(t:Transform) -> void:
	global_transform = t
	_moveYaw = rotation_degrees.y

func force_awake() -> void:
	if _state == MobState.Idle:
		_state = MobState.Hunting
	emit_mob_event("alert")

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

	# clean up old state
	if _prevState == MobState.Attacking:
		motor.set_is_attacking(false)
	
	# disable AI ticker if necessary
	if _state != MobState.Hunting:
		_ticker.stop_hunt()
	
	var _err
	# apply new state
	if _state == MobState.Hunting:
		_ticker.start_hunt()
		_thinkTick = _stats.moveTime
		_err = sprite.play_animation("walk")
	elif _state == MobState.Attacking:
		_err = sprite.play_animation("aim")
		motor.set_is_attacking(true)
	elif _state == MobState.Stunned:
		pass
	elif _state == MobState.Idle:
		motor.clear_target()
	elif _state == MobState.Spawning:
		pass
	elif _state == MobState.Dying:
		_err = sprite.play_animation("dying")
		# collisionShape.disabled = true
		self.collision_layer = Interactions.CORPSE
		self.collision_mask = Interactions.WORLD | Interactions.ACTOR_BARRIER
	elif _state == MobState.Dead:
		pass
	elif _state == MobState.Gibbing:
		_err = sprite.play_animation("dead_gib")
		collisionShape.disabled = true
		sprite.visible = false
	elif _state == MobState.Gibbed:
		_err = sprite.play_animation("dead_gib")
		collisionShape.disabled = true
		sprite.visible = false
		pass

func _tick_stunned(_delta:float) -> void:
	if _thinkTick <= 0:
		_change_state(_prevState)
		motor.set_stunned(false)
		return
	else:
		_thinkTick -= _delta
	motor.move_idle(_delta)
	# velocity = self.move_and_slide(velocity)
	# velocity *= 0.95


func face_target_flat(tar:Vector3) -> void:
	var pos:Vector3 = global_transform.origin
	tar.y = pos.y
	look_at(tar, Vector3.UP)

var _tarInfoFields = [ "id", "position", "forward", "flatForward", "yawDegrees" ]

func build_tick_info(targetInfo:Dictionary) -> void:
	if targetInfo.id == 0:
		_tickInfo.id = 0
		return
	# copy targetting data
	for key in _tarInfoFields:
		_tickInfo[key] = targetInfo[key]
	var selfPos:Vector3 = global_transform.origin
	var tarPos:Vector3 = _tickInfo.position
	_tickInfo.trueDistance = ZqfUtils.distance_between(selfPos, tarPos)
	_tickInfo.flatDistance = ZqfUtils.flat_distance_between(selfPos, tarPos)

func _process(_delta:float) -> void:
	_stunAccumulator = 0

	if _state == MobState.Hunting:
		build_tick_info(Game.mob_check_target(_tickInfo))
		if _tickInfo.id == 0:
			# lost target
			_change_state(MobState.Idle)
		else:
			_ticker.custom_tick(_delta, _tickInfo)
	
	elif _state == MobState.Idle:
		if _thinkTick <= 0:
			_thinkTick = _stats.losCheckTime
			# if Game.check_player_in_front(global_transform.origin, _moveYaw):
			# 	if Game.check_los_to_player(global_transform.origin):
			# 		_change_state(MobState.Hunting)
			# 	else:
			# 		print("Player in front but cannot see!")
			if Game.check_los_to_player(global_transform.origin):
				force_awake()
		else:
			_thinkTick -= _delta
		motor.move_idle(_delta)
		return
	elif _state == MobState.Spawning:
		return
	elif _state == MobState.Stunned:
		_tick_stunned(_delta)
		return
	elif _state == MobState.Dying:
		# velocity = self.move_and_slide(velocity)
		# velocity *= 0.95
		motor.move_idle(_delta)
		return
	elif _state == MobState.Dead:
		motor.move_idle(_delta)
		return

func apply_stun(_dir:Vector3) -> void:
	# stun
	if _state != MobState.Stunned:
		_change_state(MobState.Stunned)
		motor.set_stunned(true)
	attack.cancel()
	# velocity = _dir * 2
	_thinkTick = _stats.stunTime

func emit_mob_event(eventType:String) -> void:
	emit_signal("mob_event", eventType)

func regular_death() -> void:
	# emit_signal("mob_event", "death")
	emit_mob_event("death")
	_change_state(MobState.Dying)

func gib_death(dir:Vector3) -> void:
	emit_mob_event("gib")
	var _err = Game.spawn_gibs(global_transform.origin, dir, 8)
	_change_state(MobState.Gibbed)

func corpse_hit(_hitInfo:HitInfo) -> int:
	# print("Corpse hit - frame == " + str(sprite.get_frame_number()))
	if _hitInfo.damageType == Interactions.DAMAGE_TYPE_EXPLOSIVE:
		var gibbable:bool = (_state == MobState.Dying || _state == MobState.Dead)
		if gibbable:
			gib_death(_hitInfo.direction)
		return 1
	elif sprite.get_frame_number() <= 1:
		if _health < -_stats.health * 1000:
			gib_death(_hitInfo.direction / 10)
		else:
			_health -= _hitInfo.damage
			sprite.set_frame_number(0)
			# velocity += _hitInfo.direction * 3
			motor.damage_hit(_hitInfo)
		return 1
	else:
		return Interactions.HIT_RESPONSE_PENETRATE

func hit(_hitInfo:HitInfo) -> int:
	if is_dead():
		return corpse_hit(_hitInfo)
	_health -= _hitInfo.damage
	if _hitInfo.damageType == Interactions.DAMAGE_TYPE_EXPLOSIVE:
			print("Explosive hit for " + str(_hitInfo.damage))
	if _health <= 0:
		# die
		if _hitInfo.damageType == Interactions.DAMAGE_TYPE_EXPLOSIVE:
			gib_death(_hitInfo.direction)
		else:
			regular_death()
		motor.set_stunned(true)
		emit_signal("on_mob_died", self)
		Interactions.triggerTargets(get_tree(), triggerTargets)
		return _hitInfo.damage + _health
	else:
		# if not awake, wake up!
		force_awake()
		emit_mob_event("pain")
		_stunAccumulator += _hitInfo.damage
		if _stunAccumulator > _stats.stunThreshold:
			apply_stun(_hitInfo.direction)
		motor.damage_hit(_hitInfo)
		return _hitInfo.damage
