extends Spatial

func _process(_delta:float) -> void:
	var info = AI.get_player_target()
	if info.id == 0:
		return
	var tarPos:Vector3 = info.position
	tarPos.y = global_transform.origin.y
	ZqfUtils.look_at_safe(self, tarPos)
	pass
