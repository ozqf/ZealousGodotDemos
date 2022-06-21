extends InvWeapon

export var maxSpreadX:int = 200
export var maxSpreadY:int = 100
export var maxLoaded:int = 12

export var secondaryAmmoCost:int = 15

var _pistolShoot:AudioStream = preload("res://assets/sounds/weapon/pistol_fire.wav")
var _pistolReload:AudioStream = preload("res://assets/sounds/item/weapon_reload_light.wav")
var _awaitOff:bool = false
var _brassNode:Spatial

var _spreadScale:float = 0
var _reloading:bool = false
var _reloadTime:float = 1
var _loaded:int = 0
var _automatic:bool = true
var _prjMask:int = -1

func custom_init_b() -> void:
	_loaded = maxLoaded
	_prjMask = Interactions.get_player_prj_mask()
	_brassNode = _launchNode.find_node("ejected_brass_spawn")

# quick-switch awaaaaaaay
func is_cycling() -> bool:
	return false

func _start_reload() -> void:
	self.tick = _reloadTime
	_reloading = true

func write_hud_status(statusDict:PlayerHudStatus) -> void:
	statusDict.currentLoaded = _loaded
	statusDict.currentLoadedMax = maxLoaded
	statusDict.currentAmmo = self._inventory.get_count(self.ammoType)

func _custom_shoot(_spreadX:float, _spreadY:float, shotSpreadScale:float) -> void:
	if check_hyper_attack(Interactions.HYPER_COST_PISTOL):
		_hitInfo.stunOverrideTime = 1
		_hitInfo.stunOverrideDamage = 200
	else:
		_hitInfo.stunOverrideTime = -1
		_hitInfo.stunOverrideDamage = -1
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
		prj = Game.flare_t.instance()
		Game.get_dynamic_parent().add_child(prj)
		prj.override_damage(80)
	else:
		prj = Game.stake_t.instance()
		Game.get_dynamic_parent().add_child(prj)
		prj.override_damage(80)
	
	var t:Transform = _launchNode.global_transform
	var selfPos:Vector3 = t.origin
	var forward = -t.basis.z
	if hyper:
		prj.get_hit_info().comboType = Interactions.COMBO_CLASS_STAKE
	else:
		prj.get_hit_info().comboType = Interactions.COMBO_CLASS_STAKE
	prj.launch_prj(selfPos, forward, Interactions.PLAYER_RESERVED_ID, Interactions.TEAM_PLAYER, _prjMask)

func read_input(_weaponInput:WeaponInput) -> void:
	if _reloading:
		return
	# semi-automatic mode:
	if _automatic:
		if tick > 0:
			return
	else:
		if tick > refireTime / 2:
			return
		if _awaitOff:
			if !_weaponInput.primaryOn:
				_awaitOff = false
			return
	# if tick > 0:
	# 	return
	if _weaponInput.primaryOn:
		_awaitOff = true
		tick = refireTime
		# var t:Transform = _launchNode.global_transform
		# var forward:Vector3 = -_launchNode.global_transform.basis.z
		# var spreadX:float = rand_range(-maxSpreadX, maxSpreadX) * _spreadScale
		# var spreadY:float = rand_range(-maxSpreadY, maxSpreadY) * _spreadScale
		# forward = ZqfUtils.calc_forward_spread_from_basis(t.origin, t.basis, spreadX, spreadY)
		# _fire_single(forward, 1000)
		_custom_shoot(maxSpreadX, maxSpreadY, _spreadScale)
		.play_fire_1(false)
		Game.spawn_ejected_bullet(_brassNode.global_transform.origin, _brassNode.global_transform.basis.y, 1, 3, 1)
		# _loaded -= 1

		# apply some inaccuracy for next shot
		_spreadScale += 0.35

		_hud.hudAudio.play_stream_weapon_1(_pistolShoot, 0.1)
		
		_inventory.take_item(ammoType, ammoPerShot)
	# reload on secondary fire button:
	# elif _secondaryOn && _loaded < maxLoaded:
	# 	_start_reload()
	elif _weaponInput.secondaryOn:
		if _inventory.get_count(ammoType) >= secondaryAmmoCost:
			_fire_flare(Game.hyperLevel > 0)
			_inventory.take_item(ammoType, secondaryAmmoCost)
		# for _i in range(0, _loaded):
		# 	_custom_shoot(2000, 1200, 1)
		_loaded = 0
	# elif _secondaryOn:
	# 	_awaitOff = true
	# 	tick = refireTime * 2.0
	# 	_fire_single(-_launchNode.global_transform.basis.z, 1000)
	# 	.play_fire_1(false)
	# 	_fire_single(-_launchNode.global_transform.basis.z, 1000)
	# 	.play_fire_1(false)
	# 	_hud.audio.stream = _pistolShoot
	# 	_hud.audio.play()
	# 	_inventory.take_item(ammoType, ammoPerShot)

	if _loaded == 0:
		_start_reload()

func _process(_delta:float) -> void:
	if tick > 0:
		tick -= _delta
	if tick <= 0 && _reloading:
		_hud.hudAudio.play_stream_weapon_2(_pistolReload, 0.0, -15)
		_reloading = false
		_loaded = maxLoaded
	if _spreadScale > 1:
		_spreadScale = 1
	if _spreadScale > 0:
		_spreadScale -= _delta
	if _spreadScale < 0:
		_spreadScale = 0
