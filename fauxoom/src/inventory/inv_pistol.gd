extends InvWeapon

var _pistolShoot:AudioStream = preload("res://assets/sounds/weapon/pistol_fire.wav")
var _awaitOff:bool = false

var _spreadScale:float = 0
var _reloading:bool = false
var _maxLoaded:int = 12
var _loaded:int = 12
var _automatic:bool = false

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
		var t:Transform = _launchNode.global_transform
		var forward:Vector3 = -_launchNode.global_transform.basis.z
		var spreadX:float = rand_range(-1000, 1000) * _spreadScale
		var spreadY:float = rand_range(-600, 600) * _spreadScale
		forward = ZqfUtils.calc_forward_spread_from_basis(t.origin, t.basis, spreadX, spreadY)
		_fire_single(forward, 1000)
		.play_fire_1(false)

		_loaded -= 1
		if _loaded == 0:
			tick = 2
			_reloading = true
			# _loaded = _maxLoaded

		# apply some inaccuracy for next shot
		_spreadScale += 0.35

		_hud.audio.pitch_scale = rand_range(0.9, 1.1)
		_hud.audio.stream = _pistolShoot
		_hud.audio.play()
		_inventory.take_item(ammoType, ammoPerShot)
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

func _process(_delta:float) -> void:
	if tick > 0:
		tick -= _delta
	if tick <= 0 && _reloading:
		_reloading = false
		_loaded = _maxLoaded
	if _spreadScale > 1:
		_spreadScale = 1
	if _spreadScale > 0:
		_spreadScale -= _delta
	if _spreadScale < 0:
		_spreadScale = 0
