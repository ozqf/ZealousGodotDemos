extends InvWeapon

@export var punchScanRange:float = 2
@export var regularDamage:int = 25
@export var superDamage:int = 200
@export var superCost:int = 20

var _charging:bool = false
var _chargeTick:float = 0.0
var _slamPos:Vector3 = Vector3()

func custom_init_b() -> void:
	_hitInfo.damageType = Interactions.DAMAGE_TYPE_PUNCH
	_hitInfo.damage = regularDamage
	_hitInfo.comboType = Interactions.COMBO_CLASS_PUNCH
	add_to_group(Groups.PLAYER_GROUP_NAME)

func _spawn_aoe(pos:Vector3) -> HyperAoe:
	var aoe = Game.get_factory().hyper_aoe_t.instance()
	Game.get_dynamic_parent().add_child(aoe)
	aoe.global_transform.origin = pos
	aoe.run_hyper_aoe(HyperAoe.TYPE_SUPER_PUNCH, 1.0)
	return aoe

func player_ground_slam_finished() -> void:
	print("Offhand finish slam")
	if _hud != null:
		_hud.play_offhand_punch()
	Game.get_factory().spawn_impact_sprite(_slamPos)
	_spawn_aoe(_slamPos)

func _punch(forward:Vector3, scanRange:float) -> Vector3:
	var mask:int = Interactions.get_player_prj_mask()
	#var mask:int = -1
	# var result = ZqfUtils.quick_hitscan3D(_launchNode, 1000, _ignoreBody, mask)
	var origin:Vector3 = _launchNode.global_transform.origin
	var result:Dictionary = ZqfUtils.hitscan_by_direction_3D(_launchNode, origin, forward, scanRange, _ignoreBody, mask)
	var hitPoint:Vector3 = origin + (forward * scanRange)
	if result:
		# var isMob:bool = Interactions.is_ray_hit_a_mob(result)
		
		var count:int = _inventory.get_count("rage")
		#if count >= superCost && isMob && Game.hyperLevel > 0:
		if count >= superCost && Game.hyperLevel > 0:
			print("Super punch")
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

func offhand_punch(_weight:float) -> void:
	# print("Punch weight time: " + str(_weight))
	var count:int = _inventory.get_count("rage")
	if _launchNode.rotation_degrees.x < -65 && count >= superCost:
		var result:Dictionary = ZqfUtils.quick_hitscan3D(_launchNode, 12, ZqfUtils.EMPTY_ARRAY, Interactions.WORLD)
		if result:
			# print("Slam!")
			_inventory.take_item("rage", superCost)
			_slamPos = result.position
			var grp:String = Groups.PLAYER_GROUP_NAME
			var fn:String = Groups.PLAYER_FN_GROUND_SLAM_START
			get_tree().call_group(grp, fn)
			return
		else:
			print("No world found for slam - regular punch")
	# print("Punch pitch: " + str(_launchNode.rotation_degrees.x))
	if _hud != null:
		_hud.play_offhand_punch()
	_punch(-_launchNode.global_transform.basis.z, punchScanRange)

func is_charging() -> bool:
	return false

func is_busy() -> bool:
	if self.tick > 0:
		return true
	if _chargeTick > 0:
		return true
	return false

func begin_charge() -> void:
	_charging = true
	_chargeTick = 0

func _process(delta) -> void:
	if self.tick > 0:
		self.tick -= delta
	if _charging:
		_chargeTick += delta

#func offhand_punch_read_input(actionName:String) -> void:
#	if _hud != null:
#		_hud.play_offhand_punch()
#	_punch(-_launchNode.global_transform.basis.z, punchScanRange)
	
