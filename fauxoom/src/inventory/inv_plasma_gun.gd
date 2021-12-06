extends InvWeapon

var _pistolShoot:AudioStream = preload("res://assets/sounds/weapon/pistol_fire.wav")
var _trail_t = preload("res://prefabs/gfx/gfx_rail_trail.tscn")

func custom_init_b() -> void:
	_hitInfo.damage = 100
	_hitInfo.damageType = Interactions.DAMAGE_TYPE_PLASMA
	print("Init plasma - dmg " + str(_hitInfo.damage) + " type " + str(_hitInfo.damageType))

# func is_cycling() -> bool:
# 	if !_equipped:
# 		return false
# 	#if tick < (refireTime - (3 * (1.0 / 10.0))):
# 	if tick < refireTime - 0.4:
# 		return false
# 	return true

func _draw_trail(origin:Vector3, dest:Vector3) -> void:
	var trail = _trail_t.instance()
	Game.get_dynamic_parent().add_child(trail)
	trail.spawn(origin, dest)

func read_input(_weaponInput:WeaponInput) -> void:
	if tick > 0:
		return
	if _weaponInput.primaryOn:
		print("Fire plasma - dmg " + str(_hitInfo.damage) + " type " + str(_hitInfo.damageType))
		tick = refireTime
		var hitPos:Vector3 = _fire_single(-_launchNode.global_transform.basis.z, 1000)
		_draw_trail(_launchNode.global_transform.origin, hitPos)
		.play_fire_1(false)
		_hud.audio.stream = _pistolShoot
		_hud.audio.play()
		_inventory.take_item(ammoType, ammoPerShot)

func _process(_delta:float) -> void:
	if tick > 0:
		if !_equipped:
			_delta /= 2.0
		tick -= _delta
