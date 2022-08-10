extends InvWeapon

var _prj_flak_t = preload("res://prefabs/projectiles/prj_flak.tscn")
var _prj_grenade_t = preload("res://prefabs/projectiles/prj_player_flak_grenade.tscn")

const PELLET_COUNT:int = 18 # 14

var _ssgShoot:AudioStream = preload("res://assets/sounds/ssg/ssg_fire.wav")
var _ssgOpen:AudioStream = preload("res://assets/sounds/ssg/ssg_open.wav")
var _ssgLoad:AudioStream = preload("res://assets/sounds/ssg/ssg_load.wav")
var _ssgClose:AudioStream = preload("res://assets/sounds/ssg/ssg_close.wav")

var _currentAnimFrame:int = 0
var _lastSoundFrame:int = -1
var _brassNode:Spatial
var _prjMask:int = -1

func custom_init_b() -> void:
	_hitInfo.damageType = Interactions.DAMAGE_TYPE_SHARPNEL
	_hitInfo.comboType = Interactions.COMBO_CLASS_SHRAPNEL
	_hitInfo.stunOverrideDamage = _hitInfo.damage * 2
	_brassNode = _launchNode.find_node("ejected_brass_spawn")
	_hudSprite = _hud.hud_get_weapon_sprite("weapon_ssg")
	_hudSprite.play(idle)
	_prjMask = Interactions.get_player_prj_mask()

func _run_fire_animation() -> void:
	_hudSprite.play(fire_1)
	_hudSprite.nextAnim = idle
	_hudSprite.run_shoot_push()
	_hud.hudAudio.play_stream_weapon_1(_ssgShoot)

	_lastSoundFrame = - 1
	_inventory.take_item(ammoType, ammoPerShot)
	self.emit_signal("weapon_action", self, "fire")

func _fire_flak(origin:Vector3, forward:Vector3) -> void:
	var prj = _prj_flak_t.instance()
	Game.get_dynamic_parent().add_child(prj)
	prj.launch_prj(origin, forward, 1, Interactions.TEAM_PLAYER, _prjMask)
	prj.get_hit_info().burnSourceMask = Interactions.BURN_SOURCE_BIT_FLAK
	pass

func _fire_grenade() -> void:
	tick = refireTime
	var origin:Vector3 = _launchNode.global_transform.origin
	var forward:Vector3 = -_launchNode.global_transform.basis.z
	var grenade = _prj_grenade_t.instance()
	Game.get_dynamic_parent().add_child(grenade)
	grenade.maxSpeed = 20.0
	grenade.gravity = -0.1
	grenade.launch_prj(origin, forward, 1, Interactions.PLAYER, _prjMask)
	grenade.ownerId = _inventory.get_owner_ent_id()
	_run_fire_animation()

func _fire(hyper:bool) -> void:
	tick = refireTime
	var t:Transform = _launchNode.global_transform
	var randSpreadX:float = 1700
	var randSpreadY:float = 600
	if hyper:
		randSpreadX = 1000
		randSpreadY = 300
	for _i in range(0, PELLET_COUNT):
		var spreadX:float = rand_range(-randSpreadX, randSpreadX)
		var spreadY:float = rand_range(-randSpreadY, randSpreadY)
		var forward:Vector3 = ZqfUtils.calc_forward_spread_from_basis(t.origin, t.basis, spreadX, spreadY)
		if hyper:
			_fire_flak(t.origin, forward)
		else:
			_fire_single(forward, 1000)
	
	#var brassForward:Vector3 = -t.basis.z + t.basis.y
	#brassForward = brassForward.normalized()
	#Game.get_factory().spawn_ejected_shell(t.origin, brassForward, 1, 3, 2)
	
	# .play_fire_1(false)
	_run_fire_animation()

# func equip() -> void:
# 	_equipped = true
# 	_hud.hide_all_sprites()
# 	_hudSprite.visible = true
	#.equip()
	# resume reload animation
	#if tick > 0.0:
	#	.play_fire_1(false)
	#	_hud.centreSprite.frame = _currentAnimFrame


func read_input(_weaponInput:WeaponInput) -> void:
	# var fireHyper:bool = false
	# if check_and_use_hyper_attack(Interactions.HYPER_COST_SHOTGUN):
	# 	fireHyper = true
	
	if tick > 0 || _inventory.get_count(ammoType) < ammoPerShot:
		return

	if _weaponInput.primaryOn:
		var hyper:bool = check_and_use_hyper_attack(Interactions.HYPER_COST_SHOTGUN)
		_fire(hyper)
		# var hyper:bool = Game.hyperLevel > 0
		# if _inventory.get_count("rage") < Interactions.HYPER_COST_SHOTGUN:
		# 	hyper = false
		# else:
		# 	_inventory.take_item("rage", Interactions.HYPER_COST_SHOTGUN)
	elif _weaponInput.secondaryOn:
		_fire_grenade()
		# if _inventory.get_count("rage") < Interactions.HYPER_COST_SHOTGUN:
		# 	return
		# _inventory.take_item("rage", Interactions.HYPER_COST_SHOTGUN)
		# _fire(true)
	elif _weaponInput.tieraryOn:
		if _inventory.get_count("rage") < Interactions.HYPER_COST_SHOTGUN:
			return
		_inventory.take_item("rage", Interactions.HYPER_COST_SHOTGUN)
		_fire(true)

func is_cycling() -> bool:
	if !Game.allowQuickSwitching:
		return .is_cycling()
	if !_equipped:
		return false
	#if tick < (refireTime - (3 * (1.0 / 10.0))):
	if tick < refireTime - Game.quickSwitchTime:
		return false
	return true

func run_reload_sounds() -> void:
	if !_equipped:
		return
	# _currentAnimFrame = _hud.centreSprite.frame
	_currentAnimFrame = _hudSprite.frame
	if _currentAnimFrame == 4 && _lastSoundFrame < 4:
		_lastSoundFrame = 4
		_hud.hudAudio.play_stream_weapon_2(_ssgOpen, 0)
		Game.get_factory().spawn_ejected_shell(_brassNode.global_transform.origin, _brassNode.global_transform.basis.y, 1, 3, 2)
	elif _currentAnimFrame == 6 && _lastSoundFrame < 6:
		_lastSoundFrame = 6
		_hud.hudAudio.play_stream_weapon_2(_ssgLoad, 0)
	elif _currentAnimFrame == 8 && _lastSoundFrame < 8:
		_lastSoundFrame = 8
		_hud.hudAudio.play_stream_weapon_2(_ssgClose, 0)

func _process(_delta:float) -> void:
	if tick > 0:
		if !_equipped:
			_delta /= 2.0
		tick -= _delta
		if _equipped:
			run_reload_sounds()
		elif tick <= 0.0 && !_equipped:
			_hud.hudAudio.play_stream_weapon_2(_ssgClose, 0)
