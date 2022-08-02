extends Spatial

onready var _scanner:ZqfVolumeScanner = $Area
export var damage:int = 150

export var explosiveRadius:float = 3

var _dead:bool = false
var _tick:int = 0

var _hitInfo:HitInfo

func _ready() -> void:
	_hitInfo = Game.new_hit_info()
	_hitInfo.attackTeam = Interactions.TEAM_PLAYER
	_hitInfo.damageType = Interactions.DAMAGE_TYPE_EXPLOSIVE

func set_hyper_level(hyperLevel:int) -> void:
	_hitInfo.hyperLevel = hyperLevel

func apply_boost(_scaleBoost:int) -> void:
	if _scaleBoost > 3:
		self.damage = 400
		self.explosiveRadius = 6
	elif _scaleBoost > 2:
		self.damage = 300
		self.explosiveRadius = 5
	elif _scaleBoost > 1:
		self.damage = 200
		self.explosiveRadius = 4

func _hit_object(body, tarPos:Vector3, dist:float) -> void:
	
	var percent:float = 1.0 - float(dist / explosiveRadius)
	# up range of damage to a 50% -> 100% range
	percent = (percent + 1.0) / 2.0
	# check and cap
	if percent > 1:
		percent = 1
	if percent < 0:
		percent = 0
	
	# scanning volume may be larger than our allowed range
	if percent == 0:
		return
	# print("Explosion percentage: " + str(percent))

	_hitInfo.damage = int(damage * percent)
	_hitInfo.direction = tarPos - _hitInfo.origin
	_hitInfo.direction = _hitInfo.direction.normalized()
	var _inflicted:int = Interactions.hit(_hitInfo, body)

func _run_hits() -> void:
	_hitInfo.origin = global_transform.origin
	if _scanner.total == 0:
		print("AoE has no hits")
		return
	pass
	print("AoE run " + str(_scanner.total) + " hits at " + str(_hitInfo.origin))
	for iterator in _scanner.bodies:
		var body:PhysicsBody = iterator as PhysicsBody
		var tarPos:Vector3
		if body.has_method("get_mass_centre"):
			tarPos = body.get_mass_centre()
		else:
			tarPos = body.global_transform.origin
		#Game.draw_trail(_hitInfo.origin, tarPos)
		body.set_collision_layer_bit(Interactions.EXPLOSION_CHECK_LAYER, true)
		var result = ZqfUtils.hitscan_by_position_3D(
			self,
			_hitInfo.origin,
			tarPos,
			ZqfUtils.EMPTY_ARRAY,
			Interactions.get_explosion_check_mask())
		body.set_collision_layer_bit(Interactions.EXPLOSION_CHECK_LAYER, false)
		
		if !result:
			# TODO: Appears to happen if raycast started INSIDE the body.
			# other than stepping backward via forward vector not sure what
			# more can be done with this.
			# worst on fast moving enemies, that can 'tunnel' forward into the projectile
			# for now we will just assume the object is 'inside' and is at distance 0
			# and pass the iterated body directly
			#print("Explosion raycast has no result??")
			_hit_object(iterator, tarPos, 0.0)
			continue
		var hitLayer:int = result.collider.get_collision_layer()
		if (hitLayer & Interactions.WORLD) != 0:
			#print("Explosion blocked by world")
			continue
		
		var dist:float = _hitInfo.origin.distance_to(result.position)
		_hit_object(body, tarPos, dist)

		#var percent:float = 1.0 - float(dist / explosiveRadius)
		## up range of damage to a 50% -> 100% range
		#percent = (percent + 1.0) / 2.0
		## check and cap
		#if percent > 1:
		#	percent = 1
		#if percent < 0:
		#	percent = 0
		#
		## scanning volume may be larger than our allowed range
		#if percent == 0:
		#	continue
		## print("Explosion percentage: " + str(percent))
		
		#_hitInfo.damage = int(damage * percent)
		#_hitInfo.direction = tarPos - _hitInfo.origin
		#_hitInfo.direction = _hitInfo.direction.normalized()
		#var _inflicted:int = Interactions.hit(_hitInfo, body)

func _physics_process(_delta:float):
	if _dead:
		return
	_tick += 1
	if _tick < 4:
		print("Tick " + str(_tick) + " - overlaps: " + str(_scanner.total))
	# need to exist for three frames for touches to have been collected
	if _tick == 3:
		print("Tick " + str(_tick) + " check hits")
		_run_hits()
		return
	elif _tick == 60:
		self.queue_free()
		_dead = true
		return
