extends InvWeapon

var _brassNode:Node3D
var _rocketShoot:AudioStream = preload("res://assets/sounds/weapon/rocket_fire.wav")
var _prjMask:int = -1

signal rocket_detonate()

func custom_init_b() -> void:
	_hitInfo.damageType = Interactions.DAMAGE_TYPE_SHARPNEL
	_brassNode = _launchNode.find_node("ejected_brass_spawn")
	_prjMask = Interactions.get_player_prj_mask()

func equip() -> void:
	_hud.centreSprite.offset.y = -60
	.equip()

func deequip() -> void:
	_hud.centreSprite.offset.y = 0
	.deequip()

func _fire_shotgun() -> void:
	var t:Transform3D = _launchNode.global_transform
	var randSpreadX:float = 500
	var randSpreadY:float = 200
	for _i in range(0, 5):
		var spreadX:float = randf_range(-randSpreadX, randSpreadX)
		var spreadY:float = randf_range(-randSpreadY, randSpreadY)
		var forward:Vector3 = ZqfUtils.calc_forward_spread_from_basis(t.origin, t.basis, spreadX, spreadY)
		_fire_single(forward, 1000)

func _fire_stasis_grenade() -> void:
	var rocket = Game.get_factory().statis_grenade_t.instance()
	Game.get_dynamic_parent().add_child(rocket)
	var t:Transform3D = _launchNode.global_transform
	var selfPos:Vector3 = t.origin
	var forward = -t.basis.z
	rocket.launch_prj(selfPos, forward, 1, Interactions.TEAM_PLAYER, _prjMask)
	rocket.ownerId = _inventory.get_owner_ent_id()
	# print("Rockets - connect signal")
	connect("rocket_detonate", rocket, "triggered_detonate")
	_hud.hudAudio.play_stream_weapon_1(_rocketShoot)
	_inventory.take_item(ammoType, ammoPerShot)
		
func read_input(_weaponInput:WeaponInput) -> void:
	if _weaponInput.secondaryOn:
		# print("Rockets - detonate")
		emit_signal("rocket_detonate")
		return
	if tick <= 0 && _weaponInput.primaryOn:
		tick = refireTime
		# _fire_shotgun()
		_fire_stasis_grenade()
		
		.play_fire_1(false)
		# _hud.hudAudio.play_stream_weapon_1(_ssgShoot)
		# _lastSoundFrame = - 1
		_inventory.take_item(ammoType, ammoPerShot)
		self.emit_signal("weapon_action", self, "fire")

func run_reload_sounds() -> void:
	pass

func _process(_delta:float) -> void:
	if tick > 0:
		if !_equipped:
			_delta /= 2.0
		tick -= _delta
		if _equipped:
			run_reload_sounds()
