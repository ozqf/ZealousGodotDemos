extends InvWeapon

var _brassNode:Spatial

func custom_init_b() -> void:
	_hitInfo.damageType = Interactions.DAMAGE_TYPE_SHARPNEL
	_brassNode = _launchNode.find_node("ejected_brass_spawn")

func equip() -> void:
	_hud.centreSprite.offset.y = -60
	.equip()

func deequip() -> void:
	_hud.centreSprite.offset.y = 0
	.deequip()

func read_input(_weaponInput:WeaponInput) -> void:
	if tick <= 0 && _weaponInput.primaryOn:
		tick = refireTime
		var t:Transform = _launchNode.global_transform
		var randSpreadX:float = 700
		var randSpreadY:float = 200
		for _i in range(0, 5):
			var spreadX:float = rand_range(-randSpreadX, randSpreadX)
			var spreadY:float = rand_range(-randSpreadY, randSpreadY)
			var forward:Vector3 = ZqfUtils.calc_forward_spread_from_basis(t.origin, t.basis, spreadX, spreadY)
			_fire_single(forward, 1000)
		
		#var brassForward:Vector3 = -t.basis.z + t.basis.y
		#brassForward = brassForward.normalized()
		#Game.spawn_ejected_shell(t.origin, brassForward, 1, 3, 2)
		
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
