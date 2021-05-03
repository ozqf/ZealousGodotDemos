extends InvWeapon


func offhand_punch() -> void:
	if _hud != null:
		_hud.play_offhand_punch()
	_fire_single(-_launchNode.global_transform.basis.z, 1.5)
