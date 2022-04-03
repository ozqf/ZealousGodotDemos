extends InvWeapon

const Enums = preload("res://src/enums.gd")

var _gas_sac_t = preload("res://prefabs/dynamic_entities/mob_gas_sac.tscn")

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

func _spawn_prefab(prefab) -> void:
	var dict:Dictionary = AI.get_player_target()
	if dict.id == 0:
		return
	var obj = prefab.instance()
	Game.get_dynamic_parent().add_child(obj)
	obj.global_transform.origin = dict.aimPos

func _spawn_minor_item(dropType:int) -> void:
	print("Spawn minor item " + str(dropType))
	var dict:Dictionary = AI.get_player_target()
	if dict.id == 0:
		return
	Game.spawn_rage_drops(dict.aimPos, dropType, 1)
	pass

func _fire_column_projectile() -> void:
	var prj = Game.prj_column_t.instance()
	Game.get_dynamic_parent().add_child(prj)
	var mask = Interactions.get_player_prj_mask()
	var selfPos:Vector3 = _launchNode.global_transform.origin
	var forward:Vector3 = -_launchNode.global_transform.basis.z
	prj.launch_prj(selfPos, forward, Interactions.PLAYER_RESERVED_ID, Interactions.TEAM_PLAYER, mask)
	# rotate by 90 degrees to make the column horizontal (so a row then...)
	# var rot:Vector3 = prj.rotation_degrees
	# rot.z = 90.0
	# prj.rotation_degrees = rot
	pass

func _fire_test_projectile() -> void:
	var t:Transform = _launchNode.global_transform
	var pos:Vector3 = t.origin + (-t.basis.z)
	PrjUtils.fire_from(pos, _launchNode, null, Game.prj_column_t)

func _fire_spike_line() -> void:
	var t:Transform = _launchNode.global_transform
	var result = ZqfUtils.hitscan_by_direction_3D(_launchNode, t.origin, -t.basis.z, 60, ZqfUtils.EMPTY_ARRAY, 1)
	var dest:Vector3 = t.origin + (-t.basis.z * 60.0)
	if result:
		dest = result.position
	var points = []
	# PrjUtils.spawn_line(t.origin, dest, 1, points)
	PrjUtils.spawn_ground_line(_launchNode, t.origin, dest, 1, points)
	var numPoints:int = points.size()
	print("Got " + str(numPoints) + " points")
	for i in range(0, numPoints):
		var p:Vector3 = points[i]
		var prj = Game.prj_spike_t.instance()
		Game.get_dynamic_parent().add_child(prj)
		prj.global_transform.origin = p
		# prj.launch_prj(p, -t.basis.z, 0, Interactions.TEAM_PLAYER, Interactions.get_player_prj_mask())

func read_input(_weaponInput:WeaponInput) -> void:
	#print("Debugger - read input")
	if tick > 0:
		#print("Debugger - ticking")
		return
	var mode = Game.debuggerMode
	var atkMode:String = Game.debuggerAtkMode
	if _weaponInput.primaryOn:
		if Game.debuggerOpen:
			return
		tick = 0.2
		if mode == Enums.DebuggerMode.Deathray:
			_fire_single(-_launchNode.global_transform.basis.z, 1000)
			tick = 0.1
		elif mode == Enums.DebuggerMode.ScanEnemy:
			raycast_for_debug_mob(-_launchNode.global_transform.basis.z)
		elif mode == Enums.DebuggerMode.AttackTest:
			if atkMode == 'spikes':
				_fire_spike_line()
			else:
				_fire_column_projectile()
			#
			#_fire_test_projectile()
			pass
		elif mode == Enums.DebuggerMode.SpawnPunk:
			_spawn_enemy(Enums.EnemyType.Punk)
		elif mode == Enums.DebuggerMode.SpawnWorm:
			_spawn_enemy(Enums.EnemyType.FleshWorm)
		elif mode == Enums.DebuggerMode.SpawnSpider:
			_spawn_enemy(Enums.EnemyType.Spider)
		elif mode == Enums.DebuggerMode.SpawnGolem:
			_spawn_enemy(Enums.EnemyType.Golem)
		elif mode == Enums.DebuggerMode.SpawnTitan:
			_spawn_enemy(Enums.EnemyType.Titan)
		elif mode == Enums.DebuggerMode.SpawnGasSac:
			_spawn_prefab(_gas_sac_t)
		
		elif mode == Enums.DebuggerMode.ItemSpawnMinorHealth:
			_spawn_minor_item(Enums.QuickDropType.Health)
		elif mode == Enums.DebuggerMode.ItemSpawnMinorRage:
			_spawn_minor_item(Enums.QuickDropType.Rage)
		elif mode == Enums.DebuggerMode.ItemSpawnMinorBonus:
			_spawn_minor_item(Enums.QuickDropType.Bonus)
		else:
			print("Unknown debug mode " + str(mode))
			tick = 1
	elif _weaponInput.secondaryOn && !_weaponInput.secondaryOnPrev:
		get_tree().call_group(Groups.PLAYER_GROUP_NAME, "player_toggle_debug_menu")
		# tick = 1
		# player_open_debug_menu
		# raycast_for_debug_mob(-_launchNode.global_transform.basis.z)

func deequip() -> void:
	.deequip()
	get_tree().call_group(Groups.PLAYER_GROUP_NAME, "player_close_debug_menu")

func _process(_delta:float) -> void:
	if tick > 0:
		tick -= _delta
