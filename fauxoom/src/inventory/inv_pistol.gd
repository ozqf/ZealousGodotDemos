extends InvWeapon

func read_input(_primaryOn:bool, _secondaryOn:bool) -> void:
	if tick > 0:
		return
	if _primaryOn:
		tick = refireTime
		_fire_single()
		print("Pistol shoot")

func _process(_delta:float) -> void:
	if tick > 0:
		tick -= _delta
