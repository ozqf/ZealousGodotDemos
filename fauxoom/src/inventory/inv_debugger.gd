extends InvWeapon

const Enums = preload("res://src/enums.gd")

func custom_init_b() -> void:
	_hitInfo.damage = 100000

func raycast_for_debug_mob(forward) -> void:
	var mask:int = Interactions.ACTORS
	var scanRange:int = 1000
	var origin:Vector3 = _launchNode.global_transform.origin
	var result:Dictionary = ZqfUtils.hitscan_by_direction_3D(_launchNode, origin, forward, scanRange, _ignoreBody, mask)
	if result && result.collider.has_method("is_mob"):
		var grp:String = Groups.ENTS_GROUP_NAME
		var fn:String = Groups.ENTS_FN_SET_DEBUG_MOB
		get_tree().call_group(grp, fn, result.collider)
	else:
		print("Found no mob to debug")

func _spawn_enemy(type) -> void:
	var dict:Dictionary = AI.get_player_target()
	if dict.id == 0:
		return
	var t:Transform = Transform()
	t.origin = dict.aimPos
	var _mob = Ents.create_mob(type, t, true)

func read_input(_weaponInput:WeaponInput) -> void:
	if tick > 0:
		return
	var mode = Game.debuggerMode
	if _weaponInput.primaryOn:
		if Game.debuggerOpen:
			return
		tick = 0.1
		if mode == Enums.DebuggerMode.Deathray:
			_fire_single(-_launchNode.global_transform.basis.z, 1000)
		elif mode == Enums.DebuggerMode.ScanEnemy:
			raycast_for_debug_mob(-_launchNode.global_transform.basis.z)
		elif mode == Enums.DebuggerMode.SpawnPunk:
			_spawn_enemy(Enums.EnemyType.Punk)
		elif mode == Enums.DebuggerMode.SpawnWorm:
			_spawn_enemy(Enums.EnemyType.Worm)
		elif mode == Enums.DebuggerMode.SpawnSpider:
			_spawn_enemy(Enums.EnemyType.Spider)
		elif mode == Enums.DebuggerMode.SpawnGolem:
			_spawn_enemy(Enums.EnemyType.Golem)
		elif mode == Enums.DebuggerMode.SpawnTitan:
			_spawn_enemy(Enums.EnemyType.Titan)
		else:
			print("Unknown debug mode " + str(mode))
			tick = 1
	elif _weaponInput.secondaryOn:
		get_tree().call_group(Groups.PLAYER_GROUP_NAME, "player_toggle_debug_menu")
		tick = 1
		# player_open_debug_menu
		# raycast_for_debug_mob(-_launchNode.global_transform.basis.z)

func deequip() -> void:
	.deequip()
	get_tree().call_group(Groups.PLAYER_GROUP_NAME, "player_close_debug_menu")

func _process(_delta:float) -> void:
	if tick > 0:
		tick -= _delta
