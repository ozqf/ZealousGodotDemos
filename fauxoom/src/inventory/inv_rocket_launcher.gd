extends InvWeapon

var _rocketShoot:AudioStream = preload("res://assets/sounds/weapon/rocket_fire.wav")
var _rocket_t = preload("res://prefabs/dynamic_entities/prj_player_rocket.tscn")
var _prjMask:int = -1

func custom_init_b() -> void:
	_prjMask = Interactions.get_player_prj_mask()

func _fire_rocket() -> void:
	var rocket = _rocket_t.instance()
	Game.get_dynamic_parent().add_child(rocket)
	var t:Transform = _launchNode.global_transform
	var selfPos:Vector3 = t.origin
	var forward = -t.basis.z
	rocket.launch_prj(selfPos, forward, Ents.PLAYER_RESERVED_ID, Interactions.TEAM_PLAYER, _prjMask)
	_hud.audio.stream = _rocketShoot
	_hud.audio.play()

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
		_fire_rocket()
		.play_fire_1(false)

func _process(_delta:float) -> void:
	if tick > 0:
		if !_equipped:
			_delta /= 2.0
		tick -= _delta
