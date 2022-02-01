extends MobAttack

func fire(target:Vector3) -> void:
	# find ground below target
	target.y += 0.5
	var result:Dictionary = ZqfUtils.hitscan_by_direction_3D(
		_launchNode,
		target,
		Vector3.DOWN,
		20,
		ZqfUtils.EMPTY_ARRAY,
		Interactions.WORLD)
	if result:
		target = result.position
	var roof:Vector3 = Game.spawn_ground_target(target, 1)
	var prj = Game.prj_point_t.instance()
	prj.spawnTime = 1
	Game.get_dynamic_parent().add_child(prj)
	prj.launch_prj(roof, Vector3.DOWN, 0, Interactions.TEAM_ENEMY, _prjMask)
