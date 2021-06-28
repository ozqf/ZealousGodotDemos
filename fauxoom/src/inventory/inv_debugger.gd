extends InvWeapon


func custom_init_b() -> void:
	_hitInfo.damage = 100000


func read_input(_primaryOn:bool, _secondaryOn:bool) -> void:
	if tick > 0:
		return
	if _primaryOn:
		tick = 0.1
		_fire_single(-_launchNode.global_transform.basis.z, 1000)
	elif _secondaryOn:
		tick = refireTime

func _process(_delta:float) -> void:
	if tick > 0:
		tick -= _delta
