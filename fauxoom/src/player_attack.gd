extends Node
class_name PlayerAttack

var _prefab_impact = preload("res://prefabs/bullet_impact.tscn")
var _prefab_blood_hit = preload("res://prefabs/blood_hit_sprite.tscn")
var _hitInfo_type = preload("res://src/defs/hit_info.gd")

var _launchNode:Spatial = null
var _parentBody:PhysicsBody = null
var _inventory:Inventory = null
var _active:bool = false
var _tick:float = 0

var _currentWeapon:String = Weapons.PistolLabel
var _pendingWeapon:String = Weapons.PistolLabel

var _refireTime:float = 1
var _extraPellets:int = 10

var _hitInfo:HitInfo = null

signal fire_ssg()
signal change_weapon(nameString)

func init_attack(launchNode:Spatial, ignoreBody:PhysicsBody, inventory:Inventory) -> void:
	_launchNode = launchNode
	_parentBody = ignoreBody
	_inventory = inventory

	_hitInfo = _hitInfo_type.new()

func set_attack_enabled(flag:bool) -> void:
	_active = flag

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
	else:
		var blood = _prefab_blood_hit.instance()
		root.add_child(blood)
		blood.global_transform.origin = result.position

func _fire_spread() -> void:
	# fire single straight forward
	_fire_single()
	var t:Transform = _launchNode.global_transform
	var origin:Vector3 = t.origin
	#var originForward:Vector3 = -t.basis.z
	#var mask:int = (1 << 0)
	var mask:int = Interactions.get_player_prj_mask()
	#var mask:int = -1
	for _i in range(0, _extraPellets):
		var spreadX:float = rand_range(-1500, 1500)
		var spreadY:float = rand_range(-400, 400)
		var forward:Vector3 = ZqfUtils.calc_forward_spread_from_basis(origin, t.basis, spreadX, spreadY)
		var result:Dictionary = ZqfUtils.hitscan_by_pos_3D(_launchNode, origin, forward, 1000, [_parentBody], mask)
		if result:
			_perform_hit(result, forward)

func _fire_single() -> void:
	var mask:int = Interactions.get_player_prj_mask()
	#var mask:int = -1
	var result = ZqfUtils.quick_hitscan3D(_launchNode, 1000, [_parentBody], mask)
	if result:
		_perform_hit(result, -_launchNode.global_transform.basis.z)
	pass

func _check_weapon_change() -> void:
	if _pendingWeapon == "":
		return
	_currentWeapon = _pendingWeapon
	_pendingWeapon = ""
	var weap = Weapons.weapons[_currentWeapon]
	_refireTime = weap.refireTime
	_extraPellets = weap.extraPellets
	self.emit_signal("change_weapon", _currentWeapon)

func _process(_delta:float) -> void:
	if _tick >= 0:
		_tick -= _delta
	if !_active:
		return
	
	if Input.is_action_just_pressed("slot_1"):
		_pendingWeapon = Weapons.PistolLabel
	if Input.is_action_just_pressed("slot_2"):
		_pendingWeapon = Weapons.DualPistolsLabel
	if Input.is_action_just_pressed("slot_3"):
		_pendingWeapon = Weapons.SuperShotgunLabel
	if Input.is_action_just_pressed("slot_4"):
		_pendingWeapon = Weapons.ChaingunLabel
	if Input.is_action_just_pressed("slot_5"):
		_pendingWeapon = Weapons.RocketLauncherLabel
	if Input.is_action_just_pressed("slot_6"):
		_pendingWeapon = Weapons.FlameThrowerLabel
	if Input.is_action_just_pressed("slot_7"):
		_pendingWeapon = Weapons.PlasmaGunLabel

	if _tick <= 0:
		_check_weapon_change()

		if Input.is_action_pressed("attack_1") || Input.is_action_pressed("move_special"):
			_tick = _refireTime
			_fire_spread()
			self.emit_signal("fire_ssg")
