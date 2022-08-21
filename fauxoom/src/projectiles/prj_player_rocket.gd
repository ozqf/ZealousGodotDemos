extends Projectile

onready var _light:OmniLight = $OmniLight
onready var _scanner:ZqfVolumeScanner = $volume_scanner
onready var _particles = $particles

func _ready():
	_hitInfo.damageType = Interactions.DAMAGE_TYPE_EXPLOSIVE
	_hitInfo.comboType = Interactions.COMBO_CLASS_ROCKET
	pass

func die() -> void:
	_particles.emitting = false
	_run_explosion_hits(_scanner.bodies)
	var origin:Vector3 = global_transform.origin
	Game.get_factory().spawn_impact_debris(origin, _deathNormal, 2, 12, 12)
	Game.get_factory().spawn_explosion_sprite(origin, _deathNormal)
	Game.get_factory().explosion_shake(origin)
	.die()

func _run_explosion_hits(bodies) -> void:
	if bodies.size() == 0:
		return
	# print("Projectile read " + str(bodies.size()) + " bodies hit")
	# _hitInfo.attackTeam = _team
	_hitInfo.damageType = Interactions.DAMAGE_TYPE_EXPLOSIVE
	_hitInfo.origin = global_transform.origin
	_hitInfo.origin -= -global_transform.basis.z * 0.2
	for iterator in bodies:
		var body:PhysicsBody = iterator as PhysicsBody
		var tarPos:Vector3
		if body.has_method("get_mass_centre"):
			tarPos = body.get_mass_centre()
		else:
			tarPos = body.global_transform.origin
		#Game.get_factory().draw_trail(_hitInfo.origin, tarPos)
		
		body.set_collision_layer_bit(Interactions.EXPLOSION_CHECK_LAYER, true)
		var result = ZqfUtils.hitscan_by_position_3D(
			self,
			_hitInfo.origin,
			tarPos,
			ZqfUtils.EMPTY_ARRAY,
			Interactions.get_explosion_check_mask())
		body.set_collision_layer_bit(Interactions.EXPLOSION_CHECK_LAYER, false)

		# TODO: Appears to happen if raycast started INSIDE the body.
		# other than stepping backward via forward vector not sure what
		# more can be done with this.
		# worst on fast moving enemies, that can 'tunnel' forward into the projectile
		if !result:
			print("Explosion raycast has no result??")
			continue
		var hitLayer:int = result.collider.get_collision_layer()
		if (hitLayer & Interactions.WORLD) != 0:
			print("Explosion blocked by world")
			continue
		
		var dist:float = _hitInfo.origin.distance_to(result.position)
		var percent:float = 1.0 - float(dist / _explosiveRadius)
		if percent > 1:
			percent = 1
		if percent < 0:
			percent = 0
		# print("Explosion percentage: " + str(percent))

		_hitInfo.damage = int(150 * percent)
		_hitInfo.direction = tarPos - _hitInfo.origin
		_hitInfo.direction = _hitInfo.direction.normalized()
		var _inflicted:int = Interactions.hit(_hitInfo, body)

func _physics_process(_delta:float) -> void:
	if _scanner.total > 0:
		_light.light_color = Color(1, 0, 0, 1)
	else:
		_light.light_color = Color(1, 1, 0, 1)
	._physics_process(_delta)
