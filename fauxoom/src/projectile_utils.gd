class_name PrjUtils


static func fire_from(
	target: Vector3,
	launch: Spatial,
	pattern: Pattern,
	projectilePrefab) -> void:
	var t:Transform = launch.global_transform
	var selfPos:Vector3 = t.origin
	var forward:Vector3 = -t.basis.z

	var _prjMask = Interactions.get_enemy_prj_mask()
	var _patternBuffer = []
	
	if pattern == null:
		var prj = projectilePrefab.instance()
		Game.get_dynamic_parent().add_child(prj)
		prj.launch_prj(selfPos, forward, 0, Interactions.TEAM_ENEMY, _prjMask)
		return
	var numItems:int = 0
	numItems = pattern.fill_items(selfPos, forward, _patternBuffer, numItems)
	# print("Pattern attack got " + str(numItems) + " items")
	for _i in range (0, numItems):
		var item:Dictionary = _patternBuffer[_i]
		var prj = projectilePrefab.instance()
		Game.get_dynamic_parent().add_child(prj)
		# var frwd:Vector3 = t.basis.xform_inv(item.forward)
		var frwd:Vector3 = item.forward
		prj.launch_prj(item.pos, frwd, 0, Interactions.TEAM_ENEMY, _prjMask)
	pass

