extends InvWeapon

var _rocketShoot:AudioStream = preload("res://assets/sounds/weapon/rocket_fire.wav")
var _prjMask:int = -1

signal rocket_detonate()

func custom_init_b() -> void:
	_prjMask = Interactions.get_player_prj_mask()

func _fire_rocket() -> void:
	var rocket = Game.rocket_t.instance()
	Game.get_dynamic_parent().add_child(rocket)
	var t:Transform = _launchNode.global_transform
	var selfPos:Vector3 = t.origin
	var forward = -t.basis.z
	rocket.launch_prj(selfPos, forward, 1, Interactions.TEAM_PLAYER, _prjMask)
	rocket.ownerId = _inventory.get_owner_ent_id()
	# print("Rockets - connect signal")
	connect("rocket_detonate", rocket, "triggered_detonate")
	_hud.hudAudio.play_stream_weapon_1(_rocketShoot)
	_inventory.take_item(ammoType, ammoPerShot)

# func is_cycling() -> bool:
# 	if !_equipped:
# 		return false
# 	#if tick < (refireTime - (3 * (1.0 / 10.0))):
# 	if tick < refireTime - 0.4:
# 		return false
# 	return true

func read_input(_weaponInput:WeaponInput) -> void:
	if _weaponInput.secondaryOn:
		# print("Rockets - detonate")
		emit_signal("rocket_detonate")
		return
	if tick > 0:
		return
	if _weaponInput.primaryOn:
		tick = refireTime
		_fire_rocket()
		.play_fire_1(false)

func _process(_delta:float) -> void:
	if tick > 0:
		if !_equipped:
			_delta /= 2.0
		tick -= _delta
