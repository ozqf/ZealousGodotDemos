extends RigidBodyProjectile

var _explosion_t = preload("res://prefabs/aoe/aoe_explosion_generic.tscn")
var _column_t = preload("res://prefabs/projectiles/prj_lightning.tscn")
var _bullet_cancel_t = preload("res://prefabs/aoe/aoe_bullet_cancel.tscn")

enum HyperCoreState {
	None,
	Stake,
	Stuck
}

onready var _bodyShape = $CollisionShape

var _worldParent:Spatial = null
var _attachParent:Spatial = null

var _coreState = HyperCoreState.None
var _area:Area
var _scaleBoost:int = 0
var _dead:bool = false
var _lastTransform:Transform = Transform.IDENTITY
var _deadBall:bool = false

var _stakeVelocity:Vector3 = Vector3()

func _custom_init() -> void:
	add_to_group(Groups.HYPER_CORES_GROUP)
	_area = $Area
	_area.set_subject(self)
	_area.connect("area_entered", self, "on_area_entered_area")
	_area.connect("body_entered", self, "on_body_entered_area")

	# self.connect("area_entered", self, "on_area_entered_body")
	# self.connect("body_entered", self, "on_body_entered_body")

func on_area_entered_area(area:Area) -> void:
	if Interactions.is_obj_a_mob(area):
		Interactions.hit(_hitInfo, area)

func on_body_entered_area(body) -> void:
	if Interactions.is_obj_a_mob(body):
		Interactions.hit(_hitInfo, body)

# func on_area_entered_body(area:Area) -> void:
# 	if _coreState != HyperCoreState.Stake:
# 		return
# 	self.mode = MODE_KINEMATIC
# 	_coreState = HyperCoreState.Stuck

func on_body_entered_body(_body) -> void:
	if _coreState != HyperCoreState.Stake:
		# bump
		#if !_deadBall && Interactions.is_obj_a_mob(_body):
		#	_deadBall = true
		#	linear_velocity = Vector3(0, 3, 0)
		return
	print("Hyper core stop")
	self.mode = MODE_KINEMATIC
	_coreState = HyperCoreState.Stuck
	global_transform = _lastTransform

func _spawn_now() -> void:
	._spawn_now()
	linear_velocity = _velocity
	pass

func spawn_explosion(pos:Vector3) -> void:
	var aoe = _explosion_t.instance()
	Game.get_dynamic_parent().add_child(aoe)
	aoe.set_hyper_level(1)
	aoe.global_transform.origin = pos
	if _scaleBoost > 0:
		aoe.damage = 400
		aoe.explosiveRadius = 6
	pass

func spawn_stun(pos:Vector3, duration:float) -> void:
	var aoe = Game.hyper_aoe_t.instance()
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
	var t:Transform = Transform.IDENTITY
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

func bullet_cancel(t:Transform) -> void:
	var aoe = _bullet_cancel_t.instance()
	Game.get_dynamic_parent().add_child(aoe)
	aoe.global_transform = t

func _refresh() -> void:
	if _scaleBoost > 0.0:
		animator.scale = Vector3(2, 2, 2)
		animator.modulate = Color(1, 0, 0)
	else:
		animator.scale = Vector3(1, 1, 1)
		animator.modulate = Color(1, 1, 1)

func _try_attach_to_mob(collider) -> void:
	if !Interactions.is_obj_a_mob(collider):
		return
	_attachParent = collider
	var t:Transform = global_transform
	_worldParent = get_parent()
	_worldParent.remove_child(self)
	_attachParent.add_child(self)
	global_transform = t
	_attachParent.connect("tree_exiting", self, "detach")

func detach():
	if _attachParent == null:
		return
	var t:Transform = _attachParent.global_transform
	_attachParent.remove_child(self)
	_attachParent.disconnect("tree_exiting", self, "detach")
	_attachParent = null
	_worldParent.add_child(self)
	# become a rigid body again
	_coreState = HyperCoreState.None
	self.mode = MODE_RIGID
	_bodyShape.disabled = false
	self.gravity_scale = 1.0
	global_transform = t

func _change_to_stake(direction:Vector3) -> int:
	# if already stuck, explode
	if _coreState == HyperCoreState.Stuck:
		print("Detonate staked core")
		spawn_explosion(self.global_transform.origin)
		self.queue_free()
		return Interactions.HIT_RESPONSE_NONE
	# turn into a stake projectile
	_stakeVelocity = direction * 50.0
	print("Change core to stake at " + str(global_transform.origin))
	self.gravity_scale = 0.0
	_bodyShape.disabled = true
	self.mode = MODE_KINEMATIC
	self.linear_velocity = _stakeVelocity
	_coreState = HyperCoreState.Stake
	print("\tChanged at " + str(global_transform.origin))
	return Interactions.HIT_RESPONSE_ABSORBED

func _step_as_stake(delta:float) -> void:
	var dir:Vector3 = self._stakeVelocity.normalized()
	var step:Vector3 = self._stakeVelocity * delta
	# step back a little
	var origin:Vector3 = self.global_transform.origin - (dir * 0.1)
	var dest:Vector3 = origin + step
	var mask:int = Interactions.get_player_prj_mask()
	var arr = [ self, _area ]
	var result:Dictionary = ZqfUtils.hitscan_by_position_3D(self, origin, dest, arr, mask)
	if result:
		print("Stake hit node: " + str(result.collider.name))
		_coreState = HyperCoreState.Stuck
		global_transform.origin = result.position
		_try_attach_to_mob(result.collider)	
		return
	self.global_transform.origin = dest

func hit(_hitInfo:HitInfo) -> int:
	if _dead:
		return Interactions.HIT_RESPONSE_NONE
	
	var combo:int = _hitInfo.comboType
	if combo == Interactions.COMBO_CLASS_RAILGUN:
		if _hitInfo.hyperLevel > 0:
			railshot_links()
		else:
			bullet_cancel(self.global_transform)
	elif combo == Interactions.COMBO_CLASS_SHRAPNEL:
		spawn_shrapnel_bomb(self.global_transform.origin)
	elif combo == Interactions.COMBO_CLASS_PUNCH:
		self.linear_velocity = Vector3(0.0, 10.0, 0.0)
		return Interactions.HIT_RESPONSE_ABSORBED
	elif combo == Interactions.COMBO_CLASS_STAKE:
		return _change_to_stake(_hitInfo.direction)
	elif combo == Interactions.COMBO_CLASS_ROCKET:
		_scaleBoost += 1
		_refresh()
		return Interactions.HIT_RESPONSE_ABSORBED
	elif combo == Interactions.COMBO_CLASS_SAWBLADE:
		return _change_to_stake(_hitInfo.direction)
	else:
		spawn_explosion(self.global_transform.origin)
	_dead = true
	self.queue_free()
	return Interactions.HIT_RESPONSE_ABSORBED

func _physics_process(_delta:float) -> void:
	if _coreState == HyperCoreState.Stake:
		#print("Step stake from " + str(global_transform.origin))
		_step_as_stake(_delta)
	_lastTransform = global_transform
