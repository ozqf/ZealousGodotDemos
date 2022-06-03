extends MobAttack

func fire(_target:Vector3) -> void:
	var t:Transform = _launchNode.global_transform
	var result = ZqfUtils.hitscan_by_direction_3D(_launchNode, t.origin, -t.basis.z, 60, ZqfUtils.EMPTY_ARRAY, 1)
	var dest:Vector3 = t.origin + (-t.basis.z * 60.0)
	if result:
		dest = result.position
	var points = []
	# PrjUtils.spawn_line(t.origin, dest, 1, points)
	PrjUtils.spawn_ground_line(_launchNode, t.origin, dest, 1, points)
	var numPoints:int = points.size()
	# print("Line atk got " + str(numPoints) + " points")
	for i in range(0, numPoints):
		var p:Vector3 = points[i]
		var prj = Game.prj_spike_t.instance()
		Game.get_dynamic_parent().add_child(prj)
		prj.global_transform.origin = p
		prj.wait(0.02 * i)
		# prj.launch_prj(p, -t.basis.z, 0, Interactions.TEAM_PLAYER, Interactions.get_player_prj_mask())
	pass
