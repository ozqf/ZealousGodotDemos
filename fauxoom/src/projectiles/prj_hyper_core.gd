extends RigidBodyProjectile

var _explosion_t = preload("res://prefabs/aoe/aoe_explosion_generic.tscn")

enum HyperCoreState {
	None,
	Stake,
	Stuck
}

var _coreState = HyperCoreState.None
var _area:Area
var _scaleBoost:int = 0
var _dead:bool = false

func _custom_init() -> void:
	_area = $Area
	_area.set_subject(self)
	_area.connect("area_entered", self, "on_area_entered_area")
	_area.connect("body_entered", self, "on_body_entered_area")

	# self.connect("area_entered", self, "on_area_entered_body")
	self.connect("body_entered", self, "on_body_entered_body")
	pass

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
		return
	print("Hyper core stop")
	self.mode = MODE_KINEMATIC
	_coreState = HyperCoreState.Stuck

func _spawn_now() -> void:
	._spawn_now()
	linear_velocity = _velocity
	pass

func spawn_explosion(pos:Vector3) -> void:
	var aoe = _explosion_t.instance()
	Game.get_dynamic_parent().add_child(aoe)
	aoe.global_transform.origin = pos
	if _scaleBoost > 0:
		aoe.damage = 400
		aoe.explosiveRadius = 6
	pass

func spawn_lightning_orb(pos:Vector3) -> void:
	var aoe = Game.hyper_aoe_t.instance()
	Game.get_dynamic_parent().add_child(aoe)
	aoe.global_transform.origin = pos
	aoe.run_hyper_aoe(HyperAoe.TYPE_SUPER_PUNCH, 1.0)
	if _scaleBoost > 0:
		spawn_explosion(pos)

func spawn_shrapnel_bomb(pos:Vector3) -> void:
	spawn_explosion(pos)

func _refresh() -> void:
	if _scaleBoost > 0.0:
		animator.scale = Vector3(2, 2, 2)
		animator.modulate = Color(1, 0, 0)
	else:
		animator.scale = Vector3(1, 1, 1)
		animator.modulate = Color(1, 1, 1)

func hit(_hitInfo:HitInfo) -> int:
	if _dead:
		return Interactions.HIT_RESPONSE_NONE
	
	var combo:int = _hitInfo.comboType
	if combo == Interactions.COMBO_CLASS_RAILGUN:
		spawn_lightning_orb(self.global_transform.origin)
	elif combo == Interactions.COMBO_CLASS_SHRAPNEL:
		spawn_shrapnel_bomb(self.global_transform.origin)
	elif combo == Interactions.COMBO_CLASS_PUNCH:
		self.linear_velocity = Vector3(0.0, 10.0, 0.0)
		return Interactions.HIT_RESPONSE_ABSORBED
	elif combo == Interactions.COMBO_CLASS_STAKE:
		# if already stuck, explode
		if _coreState == HyperCoreState.Stuck:
			spawn_explosion(self.global_transform.origin)	
			self.queue_free()
			return Interactions.HIT_RESPONSE_NONE
		# turn into a stake projectile
		self.gravity_scale = 0.0
		self.linear_velocity = _hitInfo.direction * 50.0
		_coreState = HyperCoreState.Stake
		return Interactions.HIT_RESPONSE_ABSORBED
	elif combo == Interactions.COMBO_CLASS_ROCKET:
		_scaleBoost += 1
		_refresh()
		return Interactions.HIT_RESPONSE_ABSORBED
	elif combo == Interactions.COMBO_CLASS_SAWBLADE:
		if _coreState != HyperCoreState.Stuck:
			self.linear_velocity = _hitInfo.direction * 30.0
		return Interactions.HIT_RESPONSE_NONE
	else:
		print("Hyper Core popped by dmg type " + str(_hitInfo.damageType))
		spawn_explosion(self.global_transform.origin)
	_dead = true
	self.queue_free()
	return Interactions.HIT_RESPONSE_ABSORBED
