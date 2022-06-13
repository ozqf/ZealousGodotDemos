extends InvWeapon

var _pistolShoot:AudioStream = preload("res://assets/sounds/weapon/pistol_fire.wav")
var _column_t = preload("res://prefabs/projectiles/prj_lightning.tscn")

func custom_init_b() -> void:
	_hitInfo.damage = 100
	_hitInfo.damageType = Interactions.DAMAGE_TYPE_PLASMA
	_hitInfo.comboType = Interactions.COMBO_CLASS_RAILGUN
	print("Init plasma - dmg " + str(_hitInfo.damage) + " type " + str(_hitInfo.damageType))

# func is_cycling() -> bool:
# 	if !_equipped:
# 		return false
# 	#if tick < (refireTime - (3 * (1.0 / 10.0))):
# 	if tick < refireTime - 0.4:
# 		return false
# 	return true

func _draw_trail(origin:Vector3, dest:Vector3) -> void:
	var trail = Game.trail_t.instance()
	Game.get_dynamic_parent().add_child(trail)
	trail.spawn(origin, dest)

func _fire_regular() -> void:
	_hitInfo.hyperLevel = 0
	tick = refireTime
	var hitPos:Vector3 = _fire_single(-_launchNode.global_transform.basis.z, 1000)
	_draw_trail(_launchNode.global_transform.origin, hitPos)
	.play_fire_1(false)
	_hud.hudAudio.play_stream_weapon_1(_pistolShoot, 0.1)
	_inventory.take_item(ammoType, ammoPerShot)

func _fire_special() -> void:
	_hitInfo.hyperLevel = 1
	tick = refireTime
	var t:Transform = _launchNode.global_transform
	var origin:Vector3 = t.origin
	var scale:float = 1000
	var result:Dictionary = ZqfUtils.quick_hitscan3D(_launchNode, scale, ZqfUtils.EMPTY_ARRAY, Interactions.WORLD)
	if result:
		scale = origin.distance_to(result.position)
	var column = _column_t.instance()
	column.spawn(t, scale)
	Game.get_dynamic_parent().add_child(column)
	# column.global_transform = t
	# column.scale = Vector3(1.0, 1.0, scale)
	# Game.get_dynamic_parent().add_child(column)
	# print("Create column at " + str(t.origin) + " scale " + str(scale))

func read_input(_weaponInput:WeaponInput) -> void:
	if tick > 0:
		return
	if _weaponInput.primaryOn:
		# print("Fire plasma - dmg " + str(_hitInfo.damage) + " type " + str(_hitInfo.damageType))
		if check_hyper_attack(Interactions.HYPER_COST_PLASMA):
			_fire_special()
		else:
			_fire_regular()

func _process(_delta:float) -> void:
	if tick > 0:
		# if !_equipped:
		# 	_delta /= 2.0
		tick -= _delta
