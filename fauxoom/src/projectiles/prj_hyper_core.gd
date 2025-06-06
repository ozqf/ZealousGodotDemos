extends RigidBodyProjectile
class_name PrjHyperCore

var _explosion_t = preload("res://prefabs/aoe/aoe_explosion_generic.tscn")
var _column_t = preload("res://prefabs/projectiles/prj_lightning.tscn")
var _bullet_cancel_t = preload("res://prefabs/aoe/aoe_bullet_cancel.tscn")

enum HyperCoreState {
	None,
	Stake,
	Stuck,
	Gathered
}

@onready var _bodyShape = $CollisionShape
@onready var _particles = $Particles
@onready var _light:OmniLight3D = $OmniLight
@onready var _area:Area3D = $Area
@onready var _areaShape = $Area/CollisionShape

var _worldParent:Node3D = null
var _attachParent:Node3D = null
# gather object can be a rigidbody which we can't just attach to...?
var _gatherParent:Node3D = null

var _fuseLit:bool = false
var _fuseTime:float = 4.0
var _fuseTick:float = 4.0

var _coreState = HyperCoreState.None
var _scaleBoost:int = 0
var _dead:bool = false
var _lastTransform:Transform3D = Transform3D.IDENTITY
var _deadBall:bool = false
var _originGravityScale:float = 1.0

var _volatile:bool = false

var _stakeVelocity:Vector3 = Vector3()

func _ready() -> void:
	# light_fuse()
	_originGravityScale = self.gravity_scale
	timeToLive = 999
	add_to_group(Groups.HYPER_CORES_GROUP)
	_area.set_subject(self)
	_area.connect("area_entered", on_area_entered_area)
	_area.connect("body_entered", on_body_entered_area)
	_time = 999
	# self.connect("area_entered", self, "on_area_entered_body")
	self.connect("body_entered", on_body_entered_body)

func _custom_init() -> void:
	pass

func core_collect() -> void:
	_dead = true
	self.queue_free()

func on_area_entered_area(area:Area3D) -> void:
	Interactions.hit(_hitInfo, area)
	# if Interactions.is_obj_a_mob(area):
		# # 
		# Interactions.hit(_hitInfo, area)

func on_body_entered_area(body) -> void:
	if Interactions.is_obj_a_mob(body):
		# if thrown and not a stake kick upward if we fly horizontally
		# into an enemy
		if _coreState == HyperCoreState.None:
			var vel:Vector3 = self.linear_velocity
			vel.y = 0.0
			if vel.length() > 0.2:
				_kick_up()
		Interactions.hit(_hitInfo, body)

# func on_area_entered_body(area:Area3D) -> void:
# 	if _coreState != HyperCoreState.Stake:
# 		return
# 	self.mode = MODE_KINEMATIC
# 	_coreState = HyperCoreState.Stuck

func on_body_entered_body(_body) -> void:
	if _coreState != HyperCoreState.Stake:
		print("Hypercore - body entered in non-stake mode")
		if _volatile:
			spawn_explosion(self.global_transform.origin)
			_remove_self()
		# bump
		#if !_deadBall && Interactions.is_obj_a_mob(_body):
		#	_deadBall = true
		#	linear_velocity = Vector3(0, 3, 0)
		return
	#print("Hyper core stop")
	#self.mode = MODE_KINEMATIC
	#_coreState = HyperCoreState.Stuck
	#global_transform = _lastTransform]

func _spawn_now() -> void:
	super._spawn_now()
	linear_velocity = _velocity
	pass

func spawn_explosion(pos:Vector3) -> void:
	var aoe = _explosion_t.instance()
	Game.get_dynamic_parent().add_child(aoe)
	aoe.set_hyper_level(1)
	aoe.global_transform.origin = pos
	aoe.apply_boost(_scaleBoost)
	# Game.get_factory().spawn_explosion_sprite(pos, Vector3.UP)

func _apply_kinetic_push(dir:Vector3) -> void:
	detach()
	self.linear_velocity = dir * 25.0

func light_fuse() -> void:
	_reset_fuse_time()
	_fuseLit = true
	_particles.emitting = true

func cancel_fuse() -> void:
	_reset_fuse_time()
	_fuseLit = false
	_particles.emitting = false

func _reset_fuse_time() -> void:
	_fuseTick = _fuseTime

func spawn_stun(pos:Vector3, duration:float) -> void:
	var aoe = Game.get_factory().hyper_aoe_t.instance()
	Game.get_dynamic_parent().add_child(aoe)
	aoe.global_transform.origin = pos
	aoe.run_hyper_aoe(HyperAoe.TYPE_SUPER_PUNCH, duration)
	if _scaleBoost > 0:
		spawn_explosion(pos)

func spawn_shrapnel_bomb(pos:Vector3) -> void:
	#spawn_explosion(pos)
	spawn_stun(pos, 2.0)

func _spawn_rail_shot(a:Vector3, b:Vector3) -> void:
	var dist:float = a.distance_to(b)
	var column = _column_t.instance()
	var t:Transform3D = Transform3D.IDENTITY
	t.origin = a
	t = t.looking_at(b, Vector3.UP)
	column.spawn(t, dist)
	Game.get_dynamic_parent().add_child(column)

func railshot_links() -> void:
	var cores = get_tree().get_nodes_in_group(Groups.HYPER_CORES_GROUP)
	var numCores:int = cores.size()
	if numCores < 2:
		print("Not enough cores for railshot links")
		spawn_shrapnel_bomb(self.global_transform.origin)
	print("Railshot detonate sees " + str(numCores) + " cores")
	for i in range(0, numCores):
		var a = cores[i]
		bullet_cancel(a.global_transform)
		if i < (numCores - 1):
			var b = cores[i + 1]
			_spawn_rail_shot(a.global_transform.origin, b.global_transform.origin)
	pass

func bullet_cancel(t:Transform3D) -> void:
	var aoe = _bullet_cancel_t.instance()
	Game.get_dynamic_parent().add_child(aoe)
	aoe.global_transform = t
	if _scaleBoost > 0:
		spawn_explosion(t.origin)

func _refresh() -> void:
	var c:Color
	var weight:float = float(_scaleBoost) / float(3)
	animator.scale = Vector3(1, 1, 1).lerp(Vector3(2, 2, 2), weight)
	animator.modulate = Color(1, 1, 1).lerp(Color(1, 0, 0), weight)

func _attach(newParent) -> void:
	print("Hyper core - attach")
	_coreState = HyperCoreState.Stuck
	_attachParent = newParent
	var t:Transform3D = global_transform
	_worldParent = get_parent()
	_worldParent.remove_child(self)
	_attachParent.add_child(self)
	global_transform = t
	_attachParent.connect("tree_exiting", on_attach_parent_exiting_tree)

func item_projectile_gather(newParent) -> void:
	
	if _gatherParent != null:
		return
	if _gatherParent == newParent:
		return
	#print("Hyper core projectile gather")
	# we don't actually attach. physics bodies
	# can't move with each other
	# _attach(newParent)
	# self.transform.origin = Vector3()
	_coreState = HyperCoreState.Gathered
	_bodyShape.disabled = true
	_areaShape.disabled = true
	self.freeze = false
	_gatherParent = newParent
	newParent.connect("item_projectile_drop", self, "projectile_detach")
	cancel_fuse()
	pass

func projectile_detach(prj) -> void:
	prj.disconnect("item_projectile_drop", self, "projectile_detach")
	# detach()
	spawn_explosion(self.global_transform.origin)
	_remove_self()

func _try_attach_to_mob(collider) -> void:
	if !Interactions.is_obj_a_mob(collider):
		return
	_attach(collider)

func drop() -> void:
	light_fuse()
	_coreState = HyperCoreState.None
	self.freeze = false
	_bodyShape.disabled = false
	_areaShape.disabled = false
	self.gravity_scale = _originGravityScale

func on_attach_parent_exiting_tree() -> void:
	detach()

func detach():
	print("Core - detach")
	var t:Transform3D
	if _attachParent == null:
		drop()
		return
	t = _attachParent.global_transform
	_attachParent.remove_child(self)
	_attachParent.disconnect("tree_exiting",  on_attach_parent_exiting_tree)
	_attachParent = null
	_worldParent.add_child(self)
	# become a rigid body again
	drop()
	global_transform = t

func _change_to_stake(direction:Vector3) -> int:
	# if already stuck, explode
	if _coreState == HyperCoreState.Stuck:
		#print("Detonate staked core")
		spawn_explosion(self.global_transform.origin)
		self.queue_free()
		return Interactions.HIT_RESPONSE_NONE
	if _coreState == HyperCoreState.Stake:
		return Interactions.HIT_RESPONSE_ABSORBED
	# turn into a stake projectile
	cancel_fuse()
	_stakeVelocity = direction * 50.0
	#print("Change core to stake at " + str(global_transform.origin))
	self.gravity_scale = 0.0
	_bodyShape.disabled = true
	self.freeze = true
	self.linear_velocity = _stakeVelocity
	_coreState = HyperCoreState.Stake
	#print("\tChanged at " + str(global_transform.origin))
	return Interactions.HIT_RESPONSE_ABSORBED

func _step_as_stake(delta:float) -> void:
	var dir:Vector3 = self._stakeVelocity.normalized()
	var step:Vector3 = self._stakeVelocity * delta
	# step back a little
	var origin:Vector3 = self.global_transform.origin - (dir * 0.1)
	var dest:Vector3 = origin + step
	var mask:int = Interactions.get_hyper_core_mask()
	var arr = [ self, _area ]
	var result:Dictionary = ZqfUtils.hitscan_by_position_3D(self, origin, dest, arr, mask)
	if result:
		# hack to find core receptacles
		var parent = result.collider.get_parent()
		if parent.has_method("give_core"):
			result.collider.get_parent().give_core()
			_dead = true
			self.queue_free()
			return
		#print("Stake hit node: " + str(result.collider.name))
		if _volatile:
			spawn_explosion(self.global_transform.origin)
			_remove_self()
			return
		_coreState = HyperCoreState.Stuck
		# step out slightly or will be IN geometry
		var pos:Vector3 = result.position + (result.normal * 0.2)
		global_transform.origin = pos
		_try_attach_to_mob(result.collider)
		return
	self.global_transform.origin = dest

func add_boost(boost:int) -> void:
	_scaleBoost += boost
	if _scaleBoost > 3:
		_scaleBoost = 3
	_light.omni_range = 3 + _scaleBoost
	_refresh()

func _remove_self() -> void:
	_dead = true
	self.queue_free()

func _kick_up() -> void:
	detach()
	_reset_fuse_time()
	self.linear_velocity = Vector3(0.0, 10.0, 0.0)

func hit(_hitInfo:HitInfo) -> int:
	if _dead:
		return Interactions.HIT_RESPONSE_NONE
	_reset_fuse_time()
	var combo:int = _hitInfo.comboType
	print("Hyper core hit by combo type " + str(combo))
	if combo == Interactions.COMBO_CLASS_RAILGUN:
		if _hitInfo.hyperLevel > 0:
			railshot_links()
		else:
			bullet_cancel(self.global_transform)
	elif combo == Interactions.COMBO_CLASS_SHRAPNEL:
		spawn_shrapnel_bomb(self.global_transform.origin)
	elif combo == Interactions.COMBO_CLASS_PUNCH:
		# detach if attached to something
		_kick_up()
		return Interactions.HIT_RESPONSE_ABSORBED
	elif combo == Interactions.COMBO_CLASS_STAKE:
		if _hitInfo.damageType == Interactions.DAMAGE_TYPE_SAW_PROJECTILE:
			_volatile = true
		return _change_to_stake(_hitInfo.direction)
	elif combo == Interactions.COMBO_CLASS_ROCKET:
		add_boost(3)
		return Interactions.HIT_RESPONSE_ABSORBED
	elif combo == Interactions.COMBO_CLASS_FLARE:
		add_boost(1)
		_refresh()
		return Interactions.HIT_RESPONSE_ABSORBED
	elif combo == Interactions.COMBO_CLASS_SAWBLADE:
		light_fuse()
		# _volatile = true
		_apply_kinetic_push(_hitInfo.direction)
		return Interactions.HIT_RESPONSE_ABSORBED
	elif combo == Interactions.COMBO_CLASS_SAWBLADE_PROJECTILE:
		#return _change_to_stake(_hitInfo.direction)
		return Interactions.HIT_RESPONSE_ABSORBED
	else:
		spawn_explosion(self.global_transform.origin)
	_remove_self()
	return Interactions.HIT_RESPONSE_ABSORBED

func _process(_delta:float) -> void:
	if _coreState == HyperCoreState.Gathered:
		if ZqfUtils.is_obj_safe(_gatherParent):
			var followPos:Vector3 = _gatherParent.global_transform.origin
			# print("Follow pos " + str(followPos))
			self.global_transform.origin = followPos
		else:
			spawn_explosion(global_transform.origin)
			queue_free()

func _physics_process(_delta:float) -> void:
	if _coreState == HyperCoreState.Gathered:
		# physics body mode should disable this anyway
		return
	if _coreState == HyperCoreState.Stake:
		#print("Step stake from " + str(global_transform.origin))
		_step_as_stake(_delta)
	_lastTransform = global_transform
	if _fuseLit:
		_fuseTick -= _delta
		if _fuseTick <= 0.0:
			spawn_explosion(self.global_transform.origin)
			_dead = true
			self.queue_free()
