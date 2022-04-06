extends InvWeapon

var _rocketShoot:AudioStream = preload("res://assets/sounds/weapon/rocket_fire.wav")
var _prjMask:int = -1

var _lastHyperLevel:int = 0

signal rocket_detonate()

func custom_init_b() -> void:
	_prjMask = Interactions.get_player_prj_mask()

func _fire_rocket() -> void:
	# consume rage if needed since attack is the same whether in hyper or not
	var isHyper:bool = check_hyper_attack(Interactions.HYPER_COST_ROCKET)
	
	var rocket = Game.rocket_t.instance()
	Game.get_dynamic_parent().add_child(rocket)
	# make sure rocket is in tree before calling any functions
	if isHyper:
		rocket.get_hit_info().hyperLevel = 1
	else:
		rocket.get_hit_info().hyperLevel = 0
	var t:Transform = _launchNode.global_transform
	var selfPos:Vector3 = t.origin
	var forward = -t.basis.z
	rocket.launch_prj(selfPos, forward, 1, Interactions.TEAM_PLAYER, _prjMask)
	rocket.ownerId = _inventory.get_owner_ent_id()
	# print("Rockets - connect signal")
	connect("rocket_detonate", rocket, "triggered_detonate")
	_hud.hudAudio.play_stream_weapon_1(_rocketShoot)
	_inventory.take_item(ammoType, ammoPerShot)

func _fire_stasis_grenade() -> void:
	var rocket = Game.statis_grenade_t.instance()
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
		if Game.hyperLevel > 0:
			tick = 0.4
		else:
			tick = refireTime
		_fire_rocket()
		.play_fire_1(false)
	# elif _weaponInput.secondaryOn:
	# 	tick = refireTime
	# 	_fire_stasis_grenade()
	# 	.play_fire_1(false)

func _process(_delta:float) -> void:
	var hasRage:bool = _inventory.get_count("rage") >= Interactions.HYPER_COST_ROCKET
	if !hasRage && akimbo:
		akimbo = false
		if _equipped:
			play_idle()
	if Game.hyperLevel != _lastHyperLevel:
		_lastHyperLevel = Game.hyperLevel
		if Game.hyperLevel > 0 && hasRage:
			akimbo = true
		else:
			akimbo = false
		if _equipped:
			play_idle()
	if tick > 0:
		# if !_equipped:
		# 	_delta /= 2.0
		tick -= _delta
