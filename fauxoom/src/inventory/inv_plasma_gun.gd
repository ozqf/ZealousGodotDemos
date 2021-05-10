extends InvWeapon

var _pistolShoot:AudioStream = preload("res://assets/sounds/weapon/pistol_fire.wav")

func custom_init_b() -> void:
	_hitInfo.damage = 100

func is_cycling() -> bool:
	if !_equipped:
		return false
	#if tick < (refireTime - (3 * (1.0 / 10.0))):
	if tick < refireTime - 0.4:
		return false
	return true

func read_input(_primaryOn:bool, _secondaryOn:bool) -> void:
	if tick > 0:
		return
	if _primaryOn:
		tick = refireTime
		_fire_single(-_launchNode.global_transform.basis.z, 1000)
		.play_fire_1(false)
		_hud.audio.stream = _pistolShoot
		_hud.audio.play()

func _process(_delta:float) -> void:
	if tick > 0:
		if !_equipped:
			_delta /= 2.0
		tick -= _delta
