# ### MONSTERS ###

#	> mob_base
#		> ticker
#		> attack
#	> stats - stores readonly values to configure enemy health, behaviour etc

# mob_base, controls highest level state of a mob
# eg is the mob idle, alert, stunned etc.
# actual """thinking""" and attack AI is performed by
# (and overridden) in the AITicker class.
extends KinematicBody
# AITicker wants to reference mobbase class but as it is a child of mob base
# we get a circular dependency
# waiting for Godot 4 to fix this apparently...
# https://www.reddit.com/r/godot/comments/hu213d/class_was_found_in_global_scope_but_its_script/
# class_name MobBase

var _prefab_blood_hit = preload("res://prefabs/blood_hit_sprite.tscn")
var _prefab_impact_debris_t = preload("res://prefabs/gfx/blood_hit_debris.tscn")
var _punk_corpse_t = preload("res://prefabs/corpses/punk_corpse.tscn")

const Enums = preload("res://src/enums.gd")

const STUN_TIME:float = 0.2

signal on_mob_died(mob)
signal mob_event(tag)

# all this stuff is public has AITicker and attacks
# will use it
onready var sprite:CustomAnimator3D = $sprite
onready var collisionShape:CollisionShape = $body
onready var head:Spatial = $head
onready var motor:MobMotor = $motor
onready var attacks = []
onready var _stats:MobStats = $stats
onready var _ent:Entity = $Entity
onready var _ticker:AITicker = $ticker
onready var _spawnColumn:TeleportColumn = $teleport_column

export var triggerTargets:String = ""
# stoic enemies never flee
export var fleeBoredomSeconds:float = 30
# roles this mob can perform
export(Enums.EnemyRoleClass) var roleClass = Enums.EnemyRoleClass.Mix
export var corpsePrefab:String = ""

var _registered:bool = false

# optional component
var aimLaser = null
var omniCharge:OmniAttackCharge
var frameCount:int = 0

# role assigned
var roleId:int = 0
var time:float = 0

enum MobState {
	Idle,
	Spawning,
	Hunting,
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

var _aiTickInfo:AITickInfo = null

var _thinkTick:float = 0

var _stunAccumulator:int = 0
var _pushAccumulator:Vector3 = Vector3()

var _health:int = 50
var _healthMax:int = 50
var _shieldOrbTotal:int = 0
var _shieldOrbCount:int = 0
var _dead:bool = false
var _isSniper:bool = false

func _ready() -> void:
	_health = _stats.health
	if _health <= 0:
		_health = 50
	_healthMax = _health
	aimLaser = self.get_node_or_null("head/mob_aim_laser")
	omniCharge = self.get_node_or_null("head/omni_attack_charge")
	_aiTickInfo = AI.create_tick_info()
	_gather_attacks()
	motor.custom_init(self)
	motor.speed = _stats.moveSpeed
	motor.evadeSpeed = _stats.evadeSpeed
	_ticker.custom_init(self, _stats)
	add_to_group(Groups.GAME_GROUP_NAME)
	var _r = _ent.connect("entity_restore_state", self, "restore_state")
	_r = _ent.connect("entity_append_state", self, "append_state")
	_ent.triggerTargetName = triggerTargets
	AI.register_mob(self)
	_registered = true
	_change_state(MobState.Spawning)
	_find_shield_orbs()

func _find_shield_orbs() -> void:
	var orbParent:Spatial = get_node_or_null("orbs/orbs")
	if orbParent == null:
		_shieldOrbCount = 0
		return
	for orb in orbParent.get_children():
		orb.connect("shield_broke", self, "orb_shield_broke")
		orb.connect("shield_restored", self, "orb_shield_restored")
		_shieldOrbCount += 1
		_shieldOrbTotal += 1

func orb_shield_broke(index:int) -> void:
	_shieldOrbCount -= 1
	#print("Mob is down to " + str(_shieldOrbCount) + " orbs")

func orb_shield_restored(index:int) -> void:
	_shieldOrbCount += 1
	#print("Mob is up to " + str(_shieldOrbCount) + " orbs")

func get_debug_text() -> String:
	var txt:String = "prefab: " + _ent.prefabName + "\n"
	txt += "Roles: Class: " + str(roleClass) + " assigned: " + str(roleId) + "\n"
	txt += "HP: " + str(_health) + "/" + str(_healthMax)
	txt += "(" + str(get_health_percentage()) + "%)\n"
	txt += motor.get_debug_text()
	txt += _ticker.get_debug_text()
	return txt

func get_health_percentage() -> float:
	return (float(_health) / float(_healthMax)) * 100

func get_mass_centre() -> Vector3:
	return collisionShape.global_transform.origin

func _gather_attacks() -> void:
	var attackNode:Node = get_node_or_null("attacks")
	if attackNode == null:
		return
	var numAttacks:int = attackNode.get_child_count()
	for _i in range (0, numAttacks):
		var attack = attackNode.get_child(_i)
		if attack is MobAttack:
			attacks.push_back(attack)
			attack.custom_init($head, self)
	# print("Mob " + self.name + " has " + str(attacks.size()) + " attacks")

func is_mob() -> bool:
	return true

func set_trigger_names(selfName:String, targets:String) -> void:
	_ent.selfName = selfName
	_ent.triggerTargetName = targets

func set_source(node:Node, sourceId:int) -> void:
	_sourceId = sourceId
	var _r = connect("on_mob_died", node, "_on_mob_died")

func set_behaviour(sniper:bool) -> void:
	_isSniper = sniper
	_ticker.isSniper = _isSniper

func teleport(t:Transform) -> void:
	var pos = t.origin
	# print("Mob - teleport to " + str(pos))
	global_transform.origin = pos
	# TODO - apply yaw
	# global_transform = t
	# _moveYaw = rotation_degrees.y

func force_awake() -> void:
	if _state == MobState.Idle:
		_state = MobState.Hunting
	emit_mob_event("alert", -1)

func append_state(_dict:Dictionary) -> void:
	_dict.xform = ZqfUtils.transform_to_dict(global_transform)
	_dict.hp = _health
	_dict.state = _state
	_dict.prevState = _prevState
	_dict.tars = triggerTargets
	_dict.srcId = _sourceId
	_dict.snipe = _isSniper

func restore_state(_dict:Dictionary) -> void:
	global_transform = ZqfUtils.transform_from_dict(_dict.xform)
	_change_state(_dict.state)
	_prevState = _dict.prevState
	_health = _dict.hp
	# _moveYaw = _dict.yaw
	triggerTargets = _dict.tars
	set_behaviour(_dict.snipe)

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
	# if _prevState == MobState.Attacking:
	# 	motor.set_is_attacking(false)
	
	# disable AI ticker if necessary
	if _state != MobState.Hunting:
		if _prevState == MobState.Stunned:
			_ticker.stun_ended()
		else:
			_ticker.stop_hunt()
	
	var _err
	# apply new state
	if _state == MobState.Hunting:
		_ticker.start_hunt()
		_thinkTick = _stats.moveTime
		_err = sprite.play_animation("walk")
	# elif _state == MobState.Attacking:
	# 	_err = sprite.play_animation("aim")
	# 	motor.set_is_attacking(true)
	elif _state == MobState.Stunned:
		_err = sprite.play_animation("pain")
	elif _state == MobState.Idle:
		motor.clear_target()
	elif _state == MobState.Spawning:
		_spawnColumn.run(1.5)
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

func _remove_from_squad() -> void:
	if _registered:
		AI.deregister_mob(self)
		_registered = false

func _exit_tree() -> void:
	_remove_from_squad()

func face_target_flat(tar:Vector3) -> void:
	var pos:Vector3 = global_transform.origin
	tar.y = pos.y
	# look_at(tar, Vector3.UP)

func _build_tick_info(targetInfo:Dictionary, _delta:float) -> void:
	_aiTickInfo.id = targetInfo.id
	if _aiTickInfo.id == 0:
		return

	# copy targetting data
	var selfPos:Vector3 = global_transform.origin
	var tarPos:Vector3 = targetInfo.position
	_aiTickInfo.selfPos = selfPos
	_aiTickInfo.targetPos = tarPos
	_aiTickInfo.targetForward = targetInfo.forward
	_aiTickInfo.targetYaw = targetInfo.yawDegrees
	_aiTickInfo.flatVelocity = targetInfo.flatVelocity

	# fill in further details
	_aiTickInfo.trueDistance = ZqfUtils.distance_between(selfPos, tarPos)
	_aiTickInfo.flatDistance = ZqfUtils.flat_distance_between(selfPos, tarPos)
	# LoS checked from firing point, not body origin which is in the floor!
	_aiTickInfo.canSeeTarget = AI.check_los_to_player(head.global_transform.origin)
	
	# record time since a sighting of the player
	if _aiTickInfo.canSeeTarget:
		_aiTickInfo.timeSinceLastSight = 0
		_aiTickInfo.lastSeenTargetPos = tarPos
	else:
		_aiTickInfo.timeSinceLastSight += _delta
	
	# mob status
	_aiTickInfo.healthPercentage = (float(_health) / float(_healthMax)) * 100.0

func _process(_delta:float) -> void:
	time += _delta
	frameCount += 1
	_stunAccumulator = 0
	# head.rotation.y = motor.moveYaw

	if _state == MobState.Hunting:
		# build_tick_info(AI.mob_check_target(_tickInfo))
		var targetInfo:Dictionary = AI.mob_check_target()
		_build_tick_info(targetInfo, _delta)
		if _aiTickInfo.id == 0:
			# lost target
			_change_state(MobState.Idle)
		else:
			_ticker.custom_tick(_delta, _aiTickInfo)
		# sprite.yawDegrees = rad2deg(motor.moveYaw)
	elif _state == MobState.Idle:
		if _thinkTick <= 0:
			_thinkTick = _stats.losCheckTime
			# if AI.check_player_in_front(global_transform.origin, _moveYaw):
			# 	if Game.check_los_to_player(global_transform.origin):
			# 		_change_state(MobState.Hunting)
			# 	else:
			# 		print("Player in front but cannot see!")
			if AI.check_los_to_player(head.global_transform.origin):
				force_awake()
		else:
			_thinkTick -= _delta
		motor.move_idle(_delta)
		return
	elif _state == MobState.Spawning:
		if _spawnColumn.tick(_delta):
			_change_state(MobState.Idle)
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

func apply_stun(_dir:Vector3, durationOverride:float) -> void:
	# stun
	if _state != MobState.Stunned:
		_change_state(MobState.Stunned)
		motor.set_stunned(true)
	for _i in range(0, attacks.size()):
		attacks[_i].cancel()
	# velocity = _dir * 2
	var newThink:float = 0
	if durationOverride <= 0:
		newThink = _stats.stunTime
	else:
		newThink = durationOverride
	# only set stun time if it will extend current stun state.
	if _thinkTick < newThink:
		_thinkTick = newThink

func emit_mob_event(eventType:String, _index:int) -> void:
	emit_signal("mob_event", eventType, _index)

func regular_death() -> void:
	# emit_signal("mob_event", "death")
	emit_mob_event("death", -1)
	_change_state(MobState.Dying)

func gib_death(dir:Vector3) -> void:
	emit_mob_event("gib", -1)
	var _err = Game.spawn_gibs(global_transform.origin, dir, 8)
	_change_state(MobState.Gibbed)

func headshot_death() -> void:
	emit_mob_event("death", -1)
	_change_state(MobState.Dying)

func _spawn_hit_particles(pos:Vector3, _forward:Vector3,  deathHit:bool) -> void:
	var numParticles = 4
	var _range:float = 0.15
	if deathHit:
		numParticles = 12
		_range =- 0.35
	var root:Node = get_tree().get_current_scene()
	for _i in range(0, numParticles):
		var blood = _prefab_blood_hit.instance()
		root.add_child(blood)
		var offset:Vector3 = Vector3(
			rand_range(-_range, _range),
			rand_range(-_range, _range),
			rand_range(-_range, _range))
		blood.global_transform.origin = (pos + offset)
	# spawn debris particles
	var debris:Spatial = _prefab_impact_debris_t.instance()
	root.add_child(debris)
	debris.global_transform.origin = pos
	var rigidBody:RigidBody = debris.find_node("RigidBody")
	if rigidBody != null:
		var launchVel:Vector3 = -_forward
		launchVel *= rand_range(2, 12)
		rigidBody.linear_velocity = launchVel

func corpse_hit(_hitInfo:HitInfo) -> int:
	# print("Corpse hit - frame == " + str(sprite.get_frame_number()))
	if _hitInfo.damageType == Interactions.DAMAGE_TYPE_EXPLOSIVE:
		var gibbable:bool = (_state == MobState.Dying || _state == MobState.Dead)
		if gibbable:
			gib_death(_hitInfo.direction)
		return 1
	elif sprite.get_frame_number() <= 1:
		_spawn_hit_particles(_hitInfo.origin, _hitInfo.direction, false)
		if _health < -_stats.health * 5:
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
	if _state == MobState.Spawning:
		return Interactions.HIT_RESPONSE_NONE
	if _shieldOrbCount > 0:
		return Interactions.HIT_RESPONSE_NONE
	_health -= _hitInfo.damage
	if _hitInfo.damageType == Interactions.DAMAGE_TYPE_EXPLOSIVE:
			print("Explosive hit for " + str(_hitInfo.damage))
	if _health <= 0:
		# die
		_remove_from_squad()
		# triggers and important things
		motor.mob_died()
		emit_signal("on_mob_died", self)
		Interactions.triggerTargets(get_tree(), _ent.triggerTargetName)
		
		var influenceNode = get_node_or_null("influence_agent")
		if influenceNode != null:
			influenceNode.queue_free()

		# spawn drops
		if _hitInfo.damageType == Interactions.DAMAGE_TYPE_SUPER_PUNCH:
			Game.spawn_rage_drops(collisionShape.global_transform.origin, Enums.QuickDropType.Health)
		else:
			Game.spawn_rage_drops(collisionShape.global_transform.origin, Enums.QuickDropType.Rage)

		# fx
		# print("Prefab " + str(_ent.prefabName) + " died at " + str(global_transform.origin))
		# if _ent.prefabName == "mob_punk":
		if corpsePrefab == "mob_punk":
			var corpse = _punk_corpse_t.instance()
			get_tree().get_current_scene().add_child(corpse)
			corpse.spawn(_hitInfo, global_transform)
			# corpse.global_transform = global_transform
			# print("Spawned corpse at " + str(corpse.global_transform.origin))
		_change_state(MobState.Dying)
		queue_free()
		return 1
		
		# var selfPos:Vector3 = global_transform.origin
		# var hitHeight:float = _hitInfo.origin.y - selfPos.y
		# if hitHeight > 1:
		# 	headshot_death()
		# elif _hitInfo.damageType == Interactions.DAMAGE_TYPE_EXPLOSIVE:
		# 	gib_death(_hitInfo.direction)
		# else:
		# 	regular_death()
		# _spawn_hit_particles(_hitInfo.origin, _hitInfo.direction, true)
		# return _hitInfo.damage + _health
	else:
		_spawn_hit_particles(_hitInfo.origin, _hitInfo.direction, false)
		# if not awake, wake up!
		force_awake()
		emit_mob_event("pain", -1)
		_stunAccumulator += _hitInfo.damage
		if _stunAccumulator > _stats.stunThreshold:
			apply_stun(_hitInfo.direction, _hitInfo.stunOverrideTime)
		if !_isSniper:
			motor.damage_hit(_hitInfo)
		return _hitInfo.damage

func void_volume_touch() -> void:
	var info:HitInfo = Game.new_hit_info()
	info.direction = Vector3(0, 1, 0)
	info.damage = 999999
	info.damageType = Interactions.DAMAGE_TYPE_VOID
	info.origin = global_transform.origin
	hit(info)
