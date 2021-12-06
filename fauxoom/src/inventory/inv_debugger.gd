extends InvWeapon


func custom_init_b() -> void:
	_hitInfo.damage = 100000

func raycast_for_debug_mob(forward) -> void:
	var mask:int = Interactions.ACTORS
	var scanRange:int = 1000
	var origin:Vector3 = _launchNode.global_transform.origin
	var result:Dictionary = ZqfUtils.hitscan_by_pos_3D(_launchNode, origin, forward, scanRange, _ignoreBody, mask)
	if result && result.collider.has_method("is_mob"):
		var grp:String = Groups.ENTS_GROUP_NAME
		var fn:String = Groups.ENTS_FN_SET_DEBUG_MOB
		get_tree().call_group(grp, fn, result.collider)
	else:
		print("Found no mob to debug")

func read_input(_weaponInput:WeaponInput) -> void:
	if tick > 0:
		return
	if _weaponInput.primaryOn:
		tick = 0.1
		_fire_single(-_launchNode.global_transform.basis.z, 1000)
	elif _weaponInput.secondaryOn:
		tick = 0.1
		raycast_for_debug_mob(-_launchNode.global_transform.basis.z)

func _process(_delta:float) -> void:
	if tick > 0:
		tick -= _delta
