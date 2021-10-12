extends InvWeapon

export var maxSpreadX:int = 200
export var maxSpreadY:int = 100
export var maxLoaded:int = 12

var _pistolShoot:AudioStream = preload("res://assets/sounds/weapon/pistol_fire.wav")
var _pistolReload:AudioStream = preload("res://assets/sounds/item/weapon_reload_light.wav")
var _awaitOff:bool = false

var _spreadScale:float = 0
var _reloading:bool = false
var _reloadTime:float = 1
var _loaded:int = 0
var _automatic:bool = true

func custom_init_b() -> void:
	_loaded = maxLoaded

func _start_reload() -> void:
	tick = _reloadTime
	_reloading = true

func write_hud_status(statusDict:Dictionary) -> void:
	statusDict.currentLoaded = _loaded
	statusDict.currentLoadedMax = maxLoaded
	statusDict.currentAmmo = _inventory.get_count(ammoType)

func _custom_shoot(_spreadX:float, _spreadY:float, shotSpreadScale:float) -> void:
	var t:Transform = _launchNode.global_transform
	var forward:Vector3 = -_launchNode.global_transform.basis.z
	var spreadX:float = rand_range(-_spreadX, _spreadX) * shotSpreadScale
	var spreadY:float = rand_range(-_spreadY, _spreadY) * shotSpreadScale
	forward = ZqfUtils.calc_forward_spread_from_basis(t.origin, t.basis, spreadX, spreadY)
	_fire_single(forward, 1000)
	self.emit_signal("weapon_action", self, "fire")

func read_input(_primaryOn:bool, _secondaryOn:bool) -> void:
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
			if !_primaryOn:
				_awaitOff = false
			return
	# if tick > 0:
	# 	return
	if _primaryOn:
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

		_loaded -= 1

		# apply some inaccuracy for next shot
		_spreadScale += 0.35

		_hud.audio.pitch_scale = rand_range(0.9, 1.1)
		_hud.audio.stream = _pistolShoot
		_hud.audio.play()
		_inventory.take_item(ammoType, ammoPerShot)
	# reload on secondary fire button:
	# elif _secondaryOn && _loaded < maxLoaded:
	# 	_start_reload()
	elif _secondaryOn:
		for _i in range(0, _loaded):
			_custom_shoot(2000, 1200, 1)
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
		_hud.audio2.stream = _pistolReload
		_hud.audio2.play()
		_reloading = false
		_loaded = maxLoaded
	if _spreadScale > 1:
		_spreadScale = 1
	if _spreadScale > 0:
		_spreadScale -= _delta
	if _spreadScale < 0:
		_spreadScale = 0
