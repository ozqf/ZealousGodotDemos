extends Node
class_name InvWeapon

export var hudName:String = ""
export var inventoryType:String = ""
export var ammoType:String = ""
export var ammoPerShot:int = 1
export var slot:int = 1

export var idle:String = ""
export var fire_1:String = ""

export var akimbo:bool = false

var _launchNode:Spatial = null
var _inventory = null

func custom_init(inventory, launchNode:Spatial) -> void:
	_launchNode = launchNode
	_inventory = inventory

func can_equip() -> bool:
	return _inventory.get_count(ammoType) > ammoPerShot

func is_cycling() -> void:
	pass
