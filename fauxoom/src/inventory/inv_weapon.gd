extends Node
class_name InvWeapon

var _prefab_impact = preload("res://prefabs/bullet_impact.tscn")
var _prefab_blood_hit = preload("res://prefabs/blood_hit_sprite.tscn")
var _hitInfo_type = preload("res://src/defs/hit_info.gd")

export var hudName:String = ""
export var inventoryType:String = ""
export var ammoType:String = ""
export var ammoPerShot:int = 1
export var slot:int = 1

export var refireTime:float = 1.0

export var idle:String = ""
export var fire_1:String = ""

export var akimbo:bool = false

var _launchNode:Spatial = null
var _ignoreBody = []
var _inventory = null
var _hitInfo:HitInfo = null
var tick:float = 0

func custom_init(inventory, launchNode:Spatial, ignoreBody:PhysicsBody) -> void:
	_launchNode = launchNode
	_inventory = inventory
	_ignoreBody = [ ignoreBody ]
	_hitInfo = _hitInfo_type.new()

func can_equip() -> bool:
	var count:int = _inventory.get_count(ammoType)
	if count == -1:
		return true
	return count > ammoPerShot

func equip() -> void:
	print("Equip " + self.name)

func deequip() -> void:
	print("Deequip " + self.name)

func is_cycling() -> bool:
	return tick > 0

func read_input(_primaryOn:bool, _secondaryOn:bool) -> void:
	pass

func _perform_hit(result:Dictionary, forward:Vector3) -> void:
	#print("HIT at " + str(result.position))
	# result.collider etc etc
	_hitInfo.direction = forward
	var inflicted:int = Interactions.hitscan_hit(_hitInfo, result)

	var root:Node = get_tree().get_current_scene()
	if inflicted == -1:
		var impact:Spatial = _prefab_impact.instance()
		root.add_child(impact)
		var t = impact.global_transform
		t.origin = result.position
		impact.global_transform = t
	elif inflicted == -2:
		# print("Penetration hit")
		pass
	else:
		var pos = result.position
		for _i in range(0, 4):
			var blood = _prefab_blood_hit.instance()
			root.add_child(blood)
			var _range:float = 0.1
			var offset:Vector3 = Vector3(
				rand_range(-_range, _range),
				rand_range(-_range, _range),
				rand_range(-_range, _range))
			blood.global_transform.origin = (pos + offset)

func _fire_single(forward:Vector3, scanRange:float) -> void:
	var mask:int = Interactions.get_player_prj_mask()
	#var mask:int = -1
	# var result = ZqfUtils.quick_hitscan3D(_launchNode, 1000, _ignoreBody, mask)
	var origin:Vector3 = _launchNode.global_transform.origin
	var result:Dictionary = ZqfUtils.hitscan_by_pos_3D(_launchNode, origin, forward, scanRange, _ignoreBody, mask)
	if result:
		_perform_hit(result, forward)
	# perform second scan for debris that will not interfer with the damage scan
	result = ZqfUtils.quick_hitscan3D(_launchNode, 1000, _ignoreBody, Interactions.get_corpse_hit_mask())
	if result:
		_perform_hit(result, forward)
