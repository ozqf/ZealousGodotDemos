extends InvWeapon

var _ssgShoot:AudioStream = preload("res://assets/sounds/ssg/ssg_fire.wav")
var _ssgOpen:AudioStream = preload("res://assets/sounds/ssg/ssg_open.wav")
var _ssgLoad:AudioStream = preload("res://assets/sounds/ssg/ssg_load.wav")
var _ssgClose:AudioStream = preload("res://assets/sounds/ssg/ssg_close.wav")

var _lastSoundFrame:int = -1

func custom_init_b() -> void:
	_hitInfo.damageType = Interactions.DAMAGE_TYPE_SHARPNEL

func read_input(_primaryOn:bool, _secondaryOn:bool) -> void:
	if tick <= 0 && _primaryOn:
		tick = refireTime
		var t:Transform = _launchNode.global_transform
		for _i in range(0, 10):
			var spreadX:float = rand_range(-1500, 1500)
			var spreadY:float = rand_range(-400, 400)
			var forward:Vector3 = ZqfUtils.calc_forward_spread_from_basis(t.origin, t.basis, spreadX, spreadY)
			_fire_single(forward, 1000)
		.play_fire_1(false)
		_hud.audio.stream = _ssgShoot
		_hud.audio.pitch_scale = rand_range(0.85, 1)
		_hud.audio.play()
		_lastSoundFrame = - 1
		_inventory.take_item(ammoType, ammoPerShot)
		self.emit_signal("weapon_action", self, "fire")

func is_cycling() -> bool:
	if !Game.allowQuickSwitching:
		return .is_cycling()
	if !_equipped:
		return false
	#if tick < (refireTime - (3 * (1.0 / 10.0))):
	if tick < refireTime - 0.4:
		return false
	return true

func run_reload_sounds() -> void:
	if !_equipped:
		return
	var frame:int = _hud.centreSprite.frame
	if frame == 4 && _lastSoundFrame < 4:
		_lastSoundFrame = 4
		_hud.audio2.stream = _ssgOpen
		_hud.audio2.play()
	elif frame == 7 && _lastSoundFrame < 7:
		_lastSoundFrame = 7
		_hud.audio2.stream = _ssgLoad
		_hud.audio2.play()
	elif frame == 9 && _lastSoundFrame < 9:
		_lastSoundFrame = 9
		_hud.audio2.stream = _ssgClose
		_hud.audio2.play()

func _process(_delta:float) -> void:
	if tick > 0:
		if !_equipped:
			_delta /= 2.0
		tick -= _delta
		if _equipped:
			run_reload_sounds()
