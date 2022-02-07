extends MobAttack

func fire(target:Vector3) -> void:
	var wait:float = 1.0
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
	var roof:Vector3 = Game.spawn_ground_target(target, wait)
	# spawn a point projectile
	#var prj = Game.prj_point_t.instance()
	#prj.spawnTime = 1
	#Game.get_dynamic_parent().add_child(prj)
	#prj.launch_prj(roof, Vector3.DOWN, 0, Interactions.TEAM_ENEMY, _prjMask)
	# spawn a spike
	var prj = Game.prj_spike_t.instance()
	Game.get_dynamic_parent().add_child(prj)
	prj.global_transform.origin = target
	prj.wait(wait)
