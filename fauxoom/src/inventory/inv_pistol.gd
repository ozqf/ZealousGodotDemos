extends InvWeapon

export var maxSpreadX:int = 200
export var maxSpreadY:int = 100
export var maxLoaded:int = 12

export var secondaryAmmoCost:int = 15

var _pistolShoot:AudioStream = preload("res://assets/sounds/weapon/pistol_fire.wav")
var _pistolReload:AudioStream = preload("res://assets/sounds/item/weapon_reload_light.wav")
var _brassNode:Spatial
var _brassRight:Spatial
var _brassLeft:Spatial

var _spreadScale:float = 0
# var _reloading:bool = false
# var _reloadTime:float = 1
# var _loaded:int = 0
# var _automatic:bool = true
var _prjMask:int = -1

var _awaitOff:bool = false

var _offhandSprite:HudWeaponSprite = null

var _rightTick:float = 0.0
var _leftTick:float = 0.0
var _repeatFireTime:float = 0.15
var _akimboTick:float = 0.0

func custom_init_b() -> void:
	# _loaded = maxLoaded
	_prjMask = Interactions.get_player_prj_mask()
	_brassNode = _launchNode.find_node("ejected_brass_spawn")
	_brassRight = _launchNode.find_node("ejected_brass_right")
	_brassLeft = _launchNode.find_node("ejected_brass_left")
	_hudSprite = _hud.hud_get_weapon_sprite("weapon_pistol_right")
	_offhandSprite = _hud.hud_get_weapon_sprite("weapon_pistol_left")
	_hitInfo.comboType = Interactions.COMBO_CLASS_BULLET

# quick-switch awaaaaaaay
func is_cycling() -> bool:
	return false

# func _start_reload() -> void:
# 	self.tick = _reloadTime
# 	_reloading = true

func equip() -> void:
	.equip()
	_offhandSprite.visible = true

func write_hud_status(statusDict:PlayerHudStatus) -> void:
	# statusDict.currentLoaded = _loaded
	statusDict.currentLoadedMax = maxLoaded
	statusDict.currentAmmo = self._inventory.get_count(self.ammoType)

func _custom_shoot(isHyper:bool, _spreadX:float, _spreadY:float, shotSpreadScale:float) -> void:
	if isHyper:
		_hitInfo.stunOverrideTime = 1
		_hitInfo.stunOverrideDamage = 200
		_hitInfo.hyperLevel = 1
	else:
		_hitInfo.stunOverrideTime = -1
		_hitInfo.stunOverrideDamage = -1
		_hitInfo.hyperLevel = 0
	var t:Transform = self._launchNode.global_transform
	var forward:Vector3 = -_launchNode.global_transform.basis.z
	var spreadX:float = rand_range(-_spreadX, _spreadX) * shotSpreadScale
	var spreadY:float = rand_range(-_spreadY, _spreadY) * shotSpreadScale
	forward = ZqfUtils.calc_forward_spread_from_basis(t.origin, t.basis, spreadX, spreadY)
	_fire_single(forward, 1000)
	self.emit_signal("weapon_action", self, "fire")

func _fire_flare(hyper:bool) -> void:
	var prj
	if hyper:
		prj = Game.get_factory().flare_t.instance()
		Game.get_dynamic_parent().add_child(prj)
		prj.override_damage(70)
		prj.get_hit_info().burnSourceMask = Interactions.BURN_SOURCE_BIT_FLARE
		prj.get_hit_info().hyperLevel = 1
	else:
		prj = Game.get_factory().stake_t.instance()
		Game.get_dynamic_parent().add_child(prj)
		prj.override_damage(70)
	
	var t:Transform = _launchNode.global_transform
	var selfPos:Vector3 = t.origin
	var forward = -t.basis.z
	if hyper:
		prj.get_hit_info().comboType = Interactions.COMBO_CLASS_FLARE
	else:
		prj.get_hit_info().comboType = Interactions.COMBO_CLASS_STAKE
	prj.launch_prj(selfPos, forward, Interactions.PLAYER_RESERVED_ID, Interactions.TEAM_PLAYER, _prjMask)

func _spawn_brass(left:bool = false) -> void:
	var brass:Spatial = _brassRight
	if left:
		brass = _brassLeft
	Game.get_factory().spawn_ejected_bullet(brass.global_transform.origin, brass.global_transform.basis.y, 1, 3, 1)

func read_input(_weaponInput:WeaponInput) -> void:
	var rightIsReloading:bool = _rightTick > 0
	var leftIsReloading:bool = _leftTick > 0
	var akimboReady:bool = _akimboTick <= 0.0
	var ammo:int = _inventory.get_count(ammoType)

	if _awaitOff && !_weaponInput.secondaryOn:
		_awaitOff = false

	if _weaponInput.secondaryOn && !_awaitOff && ammo >= secondaryAmmoCost:
		if !rightIsReloading:
			var isHyper:bool = false
			if .check_and_use_hyper_attack(10):
				isHyper = true
			_awaitOff = true
			_fire_flare(isHyper)
			_inventory.take_item(ammoType, secondaryAmmoCost)
			_hud.hudAudio.play_stream_weapon_1(_pistolShoot, 0.1)
			_spawn_brass(false)
			_rightTick = 2.0
			_hudSprite.play(fire_1)
			_hudSprite.nextAnim = "pistol_reloading"
			_hudSprite.run_shoot_push()
			_akimboTick = _repeatFireTime
		else:
			#if !leftIsReloading && akimboReady:
			if !leftIsReloading:
				var isHyper:bool = false
				if .check_and_use_hyper_attack(10):
					isHyper = true
				_awaitOff = true
				_fire_flare(isHyper)
				_inventory.take_item(ammoType, secondaryAmmoCost)
				_hud.hudAudio.play_stream_weapon_1(_pistolShoot, 0.1)
				_spawn_brass(true)
				_leftTick = 2.0
				_offhandSprite.play(fire_1)
				_offhandSprite.nextAnim = "pistol_reloading"
				_offhandSprite.run_shoot_push()
				_akimboTick = _repeatFireTime

	rightIsReloading = _rightTick > 0
	leftIsReloading = _leftTick > 0
	akimboReady = _akimboTick <= 0.0

	if _weaponInput.primaryOn && ammo >= ammoPerShot:
		if !rightIsReloading:
			var isHyper:bool = false
			var hyperMul:float = 1.0
			var shots:int = 1
			if check_and_use_hyper_attack(Interactions.HYPER_COST_PISTOL):
				isHyper = true
				shots = 3
			# if check_can_hyper_attack(Interactions.HYPER_COST_PISTOL):
			# 	#hyperMul = 0.5
			# 	_custom_shoot(maxSpreadX, maxSpreadY, _spreadScale)
			for i in range(0, shots):
				_custom_shoot(isHyper, maxSpreadX, maxSpreadY, _spreadScale)
				_inventory.take_item(ammoType, 1)
				_spawn_brass(false)
			_hud.hudAudio.play_stream_weapon_1(_pistolShoot, 0.1)
			_rightTick = ((_repeatFireTime * 2.0) * hyperMul)
			_hudSprite.play(fire_1)
			_hudSprite.nextAnim = idle
			_akimboTick = _repeatFireTime * hyperMul
			pass
		else:
			if !leftIsReloading && akimboReady:
				var isHyper:bool = false
				var hyperMul:float = 1.0
				var shots:int = 1
				if check_and_use_hyper_attack(Interactions.HYPER_COST_PISTOL):
					shots = 3
				# if check_can_hyper_attack(Interactions.HYPER_COST_PISTOL):
				# 	hyperMul = 1
				# 	_custom_shoot(maxSpreadX, maxSpreadY, _spreadScale)
				for i in range(0, shots):
					_custom_shoot(isHyper, maxSpreadX, maxSpreadY, _spreadScale)
					_inventory.take_item(ammoType, 1)
					_spawn_brass(true)
				_hud.hudAudio.play_stream_weapon_1(_pistolShoot, 0.1)
				_leftTick = ((_repeatFireTime * 2.0) * hyperMul)
				_offhandSprite.play(fire_1)
				_offhandSprite.nextAnim = idle
				_akimboTick = _repeatFireTime * hyperMul
	pass

func _process(_delta:float) -> void:
	if _akimboTick > 0.0:
		_akimboTick -= _delta
	if _rightTick > 0.0:
		_rightTick -= _delta
		if _rightTick <= 0.0:
			_hudSprite.play(idle)
	if _leftTick > 0.0:
		_leftTick -= _delta
		if _leftTick <= 0.0:
			_offhandSprite.play(idle)
	pass

# func read_input_2(_weaponInput:WeaponInput) -> void:
# 	if _reloading:
# 		return
# 	# semi-automatic mode:
# 	if _automatic:
# 		if tick > 0:
# 			return
# 	else:
# 		if tick > refireTime / 2:
# 			return
# 		if _awaitOff:
# 			if !_weaponInput.primaryOn:
# 				_awaitOff = false
# 			return
# 	# if tick > 0:
# 	# 	return
# 	if _weaponInput.primaryOn:
# 		_awaitOff = true
# 		tick = refireTime
# 		_custom_shoot(maxSpreadX, maxSpreadY, _spreadScale)
# 		#.play_fire_1(false)
# 		Game.get_factory().spawn_ejected_bullet(_brassNode.global_transform.origin, _brassNode.global_transform.basis.y, 1, 3, 1)
# 		# apply some inaccuracy for next shot
# 		_spreadScale += 0.35

# 		_hud.hudAudio.play_stream_weapon_1(_pistolShoot, 0.1)
		
# 		_inventory.take_item(ammoType, ammoPerShot)
# 	elif _weaponInput.secondaryOn:
# 		if _inventory.get_count(ammoType) >= secondaryAmmoCost:
# 			_fire_flare(Game.hyperLevel > 0)
# 			_inventory.take_item(ammoType, secondaryAmmoCost)
# 		_loaded = 0

# 	if _loaded == 0:
# 		_start_reload()

# func _process_2(_delta:float) -> void:
# 	if tick > 0:
# 		tick -= _delta
# 	if tick <= 0 && _reloading:
# 		_hud.hudAudio.play_stream_weapon_2(_pistolReload, 0.0, -15)
# 		_reloading = false
# 		_loaded = maxLoaded
# 	if _spreadScale > 1:
# 		_spreadScale = 1
# 	if _spreadScale > 0:
# 		_spreadScale -= _delta
# 	if _spreadScale < 0:
# 		_spreadScale = 0
