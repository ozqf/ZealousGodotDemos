extends InvWeapon

var _hyper_aoe_t = preload("res://prefabs/hyper_aoe.tscn")

export var punchScanRange:float = 2
export var regularDamage:int = 15
export var superDamage:int = 100
export var superCost:int = 50

func custom_init_b() -> void:
	_hitInfo.damageType = Interactions.DAMAGE_TYPE_PUNCH
	_hitInfo.damage = regularDamage

func _spawn_aoe(pos:Vector3) -> HyperAoe:
	var aoe = _hyper_aoe_t.instance()
	Game.get_dynamic_parent().add_child(aoe)
	aoe.global_transform.origin = pos
	aoe.run_hyper_aoe(HyperAoe.TYPE_SUPER_PUNCH, 0.0)
	return aoe

func _punch(forward:Vector3, scanRange:float) -> Vector3:
	var mask:int = Interactions.get_player_prj_mask()
	#var mask:int = -1
	# var result = ZqfUtils.quick_hitscan3D(_launchNode, 1000, _ignoreBody, mask)
	var origin:Vector3 = _launchNode.global_transform.origin
	var result:Dictionary = ZqfUtils.hitscan_by_direction_3D(_launchNode, origin, forward, scanRange, _ignoreBody, mask)
	var hitPoint:Vector3 = origin + (forward * scanRange)
	if result:
		var isMob:bool = Interactions.is_ray_hit_a_mob(result)
		
		var count:int = _inventory.get_count("rage")
		if count >= superCost && isMob:
			_hitInfo.damage = superDamage
			_inventory.take_item("rage", superCost)
			_hitInfo.damageType = Interactions.DAMAGE_TYPE_SUPER_PUNCH
			_spawn_aoe(result.position)
		else:
			_hitInfo.damage = regularDamage
			_hitInfo.damageType = Interactions.DAMAGE_TYPE_PUNCH

		_perform_hit(result, forward)
		hitPoint = result.position
	# perform second scan for debris that will not interfer with the damage scan
	result = ZqfUtils.quick_hitscan3D(_launchNode, scanRange, _ignoreBody, Interactions.get_corpse_hit_mask())
	if result:
		_perform_hit(result, forward)
	return hitPoint

func offhand_punch() -> void:
	if _hud != null:
		_hud.play_offhand_punch()
	_punch(-_launchNode.global_transform.basis.z, punchScanRange)
