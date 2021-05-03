extends InvWeapon

func read_input(_primaryOn:bool, _secondaryOn:bool) -> void:
	if tick > 0:
		return
	if _primaryOn:
		tick = refireTime
		_fire_single(-_launchNode.global_transform.basis.z, 1000)
		.play_fire_1(false)
	elif _secondaryOn:
		tick = refireTime * 2.0
		_fire_single(-_launchNode.global_transform.basis.z, 1000)
		.play_fire_1(false)
		_fire_single(-_launchNode.global_transform.basis.z, 1000)
		.play_fire_1(false)

func _process(_delta:float) -> void:
	if tick > 0:
		tick -= _delta
