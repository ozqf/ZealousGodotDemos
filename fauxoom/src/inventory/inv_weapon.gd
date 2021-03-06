extends Node
class_name InvWeapon

signal weapon_action(weapon, actionName)

var _prefab_impact = preload("res://prefabs/bullet_impact.tscn")
var _prefab_blood_hit = preload("res://prefabs/blood_hit_sprite.tscn")

export var hudName:String = ""
export var inventoryType:String = ""
export var ammoType:String = ""
export var ammoPerShot:int = 1
export var slot:int = 1

export var refireTime:float = 1.0

export var idle:String = ""
export var fire_1:String = ""

export var akimbo:bool = false

var _equipped:bool = false
var _launchNode:Spatial = null
var _ignoreBody = []
var _hud = null
var _inventory = null
var _hitInfo:HitInfo = null
var tick:float = 0
var _leftNext:bool = false

#########################################
# init and select/deselect logic
#########################################
func custom_init(inventory, launchNode:Spatial, ignoreBody:PhysicsBody, hud) -> void:
	_launchNode = launchNode
	_inventory = inventory
	_ignoreBody = [ ignoreBody ]
	_hitInfo = Game.new_hit_info()
	_hud = hud
	custom_init_b()

func custom_init_b() -> void:
	pass

func can_equip() -> bool:
	if inventoryType == "":
		return true
	var weaponCount:int = _inventory.get_count(inventoryType)
	if weaponCount == 0:
		return false
	var ammoCount:int = _inventory.get_count(ammoType)
	if ammoCount == -1:
		return true
	return ammoCount > ammoPerShot

func equip() -> void:
	# print("Equip " + self.name)
	_equipped = true
	play_idle()

func deequip() -> void:
	_equipped = false

func is_cycling() -> bool:
	return tick > 0

#########################################
# default attack logic
#########################################
func play_idle() -> void:
	_hud.hide_all_sprites()
	if idle == null || idle == "":
		return
	_hud.currentIdleAnim = idle
	if akimbo:
		_hud.rightSprite.visible = true
		_hud.rightSprite.play(idle)
		_hud.leftSprite.visible = true
		_hud.leftSprite.play(idle)
	else:
		_hud.centreSprite.visible = true
		_hud.centreSprite.play(idle)

func play_fire_1(loop:bool = true) -> void:
	if _hud == null || fire_1 == null || fire_1 == "":
		return
	if akimbo:
		if _leftNext:
			_leftNext = false
			_hud.leftSprite.play(fire_1)
			_hud.leftSprite.frame = 0
			if !loop:
				_hud.leftNextAnim = idle
		else:
			_leftNext = true
			_hud.rightSprite.play(fire_1)
			_hud.rightSprite.frame = 0
			if !loop:
				_hud.rightNextAnim = idle
	else:
		_hud.centreSprite.play(fire_1)
		_hud.centreSprite.frame = 0
		if !loop:
			_hud.centreNextAnim = idle

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

func _fire_single(forward:Vector3, scanRange:float) -> Vector3:
	var mask:int = Interactions.get_player_prj_mask()
	#var mask:int = -1
	# var result = ZqfUtils.quick_hitscan3D(_launchNode, 1000, _ignoreBody, mask)
	var origin:Vector3 = _launchNode.global_transform.origin
	var result:Dictionary = ZqfUtils.hitscan_by_pos_3D(_launchNode, origin, forward, scanRange, _ignoreBody, mask)
	var hitPoint:Vector3 = origin + (forward * scanRange)
	if result:
		_perform_hit(result, forward)
		hitPoint = result.position
	# perform second scan for debris that will not interfer with the damage scan
	result = ZqfUtils.quick_hitscan3D(_launchNode, scanRange, _ignoreBody, Interactions.get_corpse_hit_mask())
	if result:
		_perform_hit(result, forward)
	return hitPoint
