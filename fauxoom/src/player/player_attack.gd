extends Node
class_name PlayerAttack

var _prefab_impact = preload("res://prefabs/bullet_impact.tscn")
var _prefab_blood_hit = preload("res://prefabs/blood_hit_sprite.tscn")
var _hitInfo_type = preload("res://src/defs/hit_info.gd")
var _rocket_t = preload("res://prefabs/dynamic_entities/prj_player_rocket.tscn")

var _launchNode:Spatial = null
var _parentBody:PhysicsBody = null
# var _inventory:Inventory = null
var _inventory = null
var _active:bool = false
var _tick:float = 0

var _meleeTick:float = 0
var _meleeTime:float = 1

var _currentWeapon:String = Weapons.PistolLabel
var _pendingWeapon:String = Weapons.PistolLabel

var _refireTime:float = 1
var _extraPellets:int = 10

var _hitInfo:HitInfo = null
var _prjMask:int = -1
var _ignore = []

func init_attack(launchNode:Spatial, ignoreBody:PhysicsBody, inventory) -> void:
	_launchNode = launchNode
	_parentBody = ignoreBody
	_ignore.push_back(_parentBody)
	_inventory = inventory
	_prjMask = Interactions.get_player_prj_mask()

	_hitInfo = _hitInfo_type.new()

func set_attack_enabled(flag:bool) -> void:
	_active = flag

func _process(_delta:float) -> void:
	if _active:
		var pendingSlot:int = -1
		if Input.is_action_just_pressed("slot_1"):
			pendingSlot = 1
		if Input.is_action_just_pressed("slot_2"):
			pendingSlot = 2
		if Input.is_action_just_pressed("slot_3"):
			pendingSlot = 3
		if Input.is_action_just_pressed("slot_4"):
			pendingSlot = 4
		if Input.is_action_just_pressed("slot_5"):
			pendingSlot = 5
		if Input.is_action_just_pressed("slot_6"):
			pendingSlot = 6
		if Input.is_action_just_pressed("slot_7"):
			pendingSlot = 7
		
		if pendingSlot != -1:
			_inventory.change_weapon_by_slot(pendingSlot)
	
	var primary:bool = Input.is_action_pressed("attack_1")
	if !_active:
		primary = false

	if _meleeTick > 0:
		primary = false
		_meleeTick -= _delta
	elif Input.is_action_just_pressed("offhand_melee"):
		_meleeTick = _meleeTime
		_inventory.offhand.offhand_punch()

	var weap:InvWeapon = _inventory.get_current_weapon()
	if weap != null:
		weap.read_input(primary, false)
