class_name PrjUtils


static func fire_from(
	_target: Vector3,
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

static func spawn_line(
	origin:Vector3,
	dest:Vector3,
	itemWidth:float,
	array) -> void:
	pass
	array.clear()
	var line:Vector3 = dest - origin
	var lineLength:float = line.length()
	var steps:int = int(lineLength / itemWidth)
	if steps <= 0:
		steps = 1
	var forward:Vector3 = line.normalized()
	var pos:Vector3 = origin + forward
	for _i in range(0, steps):
		array.push_back(pos)
		pos += forward * itemWidth

static func spawn_ground_line(
	spatial:Spatial,
	origin:Vector3,
	dest:Vector3,
	itemWidth:float,
	array) -> void:
	pass
	spawn_line(origin, dest, itemWidth, array)
	var num:int = array.size()
	for i in range(0, num):
		var forward:Vector3 = Vector3.DOWN
		var result = ZqfUtils.hitscan_by_direction_3D(
			spatial,
			array[i],
			forward,
			100,
			ZqfUtils.EMPTY_ARRAY,
			1)
		if result:
			array[i] = result.position
