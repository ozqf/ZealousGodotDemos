extends InvWeapon

var _rocketShoot:AudioStream = preload("res://assets/sounds/weapon/rocket_fire.wav")
var _prjMask:int = -1

var _lastHyperLevel:int = 0

signal rocket_detonate()
signal laser_aim_update(laserPos)

func custom_init_b() -> void:
	_hudSprite = _hud.hud_get_weapon_sprite("weapon_rl")
	_prjMask = Interactions.get_player_prj_mask()

func _fire_rocket() -> void:
	# consume rage if needed since attack is the same whether in hyper or not
	var isHyper:bool = check_and_use_hyper_attack(Interactions.HYPER_COST_ROCKET)
	
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
	connect("laser_aim_update", rocket, "laser_aim_update")
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
		#emit_signal("rocket_detonate")
		var plyr = AI.get_player_target()
		if plyr.id != 0:
			#print("Emit laser aim")
			#emit_signal("laser_aim_update", plyr.aimPos)
			var grp = Groups.PRJ_GROUP_NAME
			var fn = Groups.PRJ_FN_PLAYER_LASER_AIM_AT
			get_tree().call_group(grp, fn, plyr.aimPos, plyr.id)
	if tick > 0:
		return
	if _weaponInput.primaryOn:
		if Game.hyperLevel > 0:
			tick = 0.4
		else:
			tick = refireTime
		_fire_rocket()
		# .play_fire_1(false)
		_hudSprite.play(fire_1)
		_hudSprite.nextAnim = "rl_reload"
		_hudSprite.run_shoot_push()
	# elif _weaponInput.secondaryOn:
	# 	tick = refireTime
	# 	_fire_stasis_grenade()
	# 	.play_fire_1(false)

func _process(_delta:float) -> void:
	#var hasRage:bool = _inventory.get_count("rage") >= Interactions.HYPER_COST_ROCKET
	#if !hasRage && akimbo:
	#	akimbo = false
	#	if _equipped:
	#		play_idle()
	#if Game.hyperLevel != _lastHyperLevel:
	#	_lastHyperLevel = Game.hyperLevel
	#	if Game.hyperLevel > 0 && hasRage:
	#		akimbo = true
	#	else:
	#		akimbo = false
	#	if _equipped:
	#		play_idle()
	if tick > 0:
		# if !_equipped:
		# 	_delta /= 2.0
		tick -= _delta
		if tick <= 0:
			play_idle()
