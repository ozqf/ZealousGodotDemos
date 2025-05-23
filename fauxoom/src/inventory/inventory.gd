extends Node
# sigh... really waiting for Godot 4 and I can have two classes reference each other...
# in this case, Inventory <-> InvWeapon
# class_name Inventory
signal weapon_changed(newWeapon, oldWeapon)
signal weapon_action(weapon, actionName)

var _data:Dictionary = {
	chainsaw = { count = 0, max = 1, type = "weapon", priority = 1 },
	pistol = { count = 0, max = 2, type = "weapon", priority = 3 },
	shotgun = { count = 0, max = 1, type = "weapon", priority = 3 },
	super_shotgun = { count = 0, max = 1, type = "weapon", priority = 4 },
	plasma_gun = { count = 0, max = 1, type = "weapon", priority = 5 },
	rocket_launcher = { count = 0, max = 1, type = "weapon", priority = 6 },
	flame_thrower = { count = 0, max = 1, type = "weapon", priority = 2 },
	debugger = { count = 0, max = 1, type = "weapon", priority = 999 },

	bullets = { count = 100, max = 200, type = "ammo", priority = 0 },
	shells = { count = 0, max = 40, type = "ammo", priority = 0 },
	plasma = { count = 0, max = 20, type = "ammo", priority = 0 },
	rockets = { count = 0, max = 20, type = "ammo", priority = 0 },
	fuel = { count = 0, max = 800, type = "ammo", priority = 0 },
	
	rage = { count = 0, max = 100, type = "resource", priority = 0 },

	hazard_suit = { count = 0, max = 1, type = "equipment", priority = 0 }
}

var weapons = []
var _currentWeaponIndex:int = -1
var offhand:InvWeapon = null
var empty:InvWeapon = null
var ownerId:int = 0
var chainsawRevs:int = 0
# var _currentWeapon:InvWeapon = null

func custom_init(launchNode:Node3D, ignoreBody:PhysicsBody, hud) -> void:
	# gather weapons
	var children = $weapons.get_children()
	for child in children:
		if !(child is InvWeapon):
			continue
		
		if child.name == "offhand":
			offhand = child
		# elif child.name == "empty":
		# 	empty = child
		else:
			weapons.push_back(child)
		
		child.connect("weapon_action", self, "on_weapon_action")
		
		child.custom_init(self, launchNode, ignoreBody, hud)
		# if _currentWeapon == null:
		# 	set_current_weapon(child)
	# print("Inventory found " + str(weapons.size()) + " weapons")

	if Main.debug_mode():
		print("Running from editor - give debugger")
		give_item("debugger", 1)

	select_first_weapon()

func update_hyper_level(hyperLevel:int) -> void:
	for weap in weapons:
		weap.hyperLevel = hyperLevel
		pass

func on_weapon_action(_weapon:InvWeapon, _action:String) -> void:
	self.emit_signal("weapon_action", _weapon, _action)

func get_owner_ent_id() -> int:
	return ownerId

func append_state(_saveDict:Dictionary) -> void:
	var save = { 
		weap = _currentWeaponIndex
	}
	var keys = _data.keys()
	for key in keys:
		save[key] = _data[key].count
	
	_saveDict["inventory"] = save

func restore_state(_restoreDict:Dictionary) -> void:
	if !("inventory" in _restoreDict):
		return
	var loadData = _restoreDict["inventory"]
	var keys = _data.keys()
	for key in keys:
		if !(key in loadData):
			continue
		_data[key].count = loadData[key]
	if !("weap" in loadData):
		return
	set_current_weapon(loadData.weap)

func set_current_weapon(index:int) -> void:
	if index == _currentWeaponIndex:
		return
	# print("Set weapon index from " + str(_currentWeaponIndex) + " to " + str(index))
	var prevWeap = null
	if _currentWeaponIndex >= 0:
		prevWeap = weapons[_currentWeaponIndex]
		prevWeap.deequip()
	_currentWeaponIndex = index
	var newWeap = null
	# if index == -1:
	# 	newWeap = empty
	# 	newWeap.equip()
	if _currentWeaponIndex >= 0:
		newWeap = weapons[_currentWeaponIndex]
		# print("Equip weapon " + newWeap.name)
		newWeap.equip()
	# if newWeap != null:
	# 	print("Switched to " + newWeap.name)
	# else:
	# 	print("Switched to no weapon")
	# self.emit_signal("weapon_changed", newWeap, prevWeap)

func select_next_weapon() -> void:
	if _currentWeaponIndex == -1:
		return
	var escape:int = 0
	var i:int = _currentWeaponIndex
	while true:
		i += 1
		escape += 1
		if escape > 100:
			return
		if i >= weapons.size():
			i = 0
		var weap:InvWeapon = weapons[i]
		if weap.can_equip():
			set_current_weapon(i)
			return

# find the first selectable weapon and equip it
func select_first_weapon() -> void:
	var numWeapons:int = weapons.size()
	for i in range(0, numWeapons):
		var weap = weapons[i]
		if weap.can_equip():
			print("Select first weapon " + str(i))
			set_current_weapon(i)
			return
	print("Select first weapon " + str(-1))
	set_current_weapon(-1)

func get_current_weapon() -> InvWeapon:
	if _currentWeaponIndex == -1:
		return empty
	return weapons[_currentWeaponIndex]

# returns 1 if weapon was successfully changed
# returns 0 if weapon change is currently blocked
# returns -1 if no weapon was found
func change_weapon_by_slot(_slotNumber:int) -> int:
	# print("Change weapon by slot " + str(_slotNumber))
	# slots are 1 and up only
	if _slotNumber <= 0:
		return -1
	var numWeapons:int = weapons.size()
	var i:int = 0
	var current = get_current_weapon()
	
	# if current weapon is the same slot number, select
	# from that index onward to cycle through items in that slot
	if current != null:
		if current.is_cycling():
			return 0
		if _slotNumber == current.slot:
			i = _currentWeaponIndex + 1
			if i >= numWeapons:
				i = 0
	var fail:int = 0
	var result:int
	while true:
		var weap = weapons[i]
		if weap.slot == _slotNumber && weap.can_equip():
			result = i
			break;
		i += 1
		if i >= numWeapons:
			i = 0
		# if we've been round the list already, nothing available
		# matches this slot
		fail += 1
		if fail > numWeapons + 1:
			#print("Select by slot " + str(_slotNumber) + " ran away!")
			return -1
	if result != _currentWeaponIndex:
		set_current_weapon(result)
	return 1

func find_weapon_slot_by_name(weaponName:String) -> int:
	var num:int = weapons.size()
	for _i in range(0, num):
		if weapons[_i].inventoryType == weaponName:
			#print("Found slot " + str(weapons[_i].slot) + " for item " + weaponName)
			return weapons[_i].slot
	#print("Found no slot for weapon " + weaponName)
	return -1

func write_hud_status(_hudStatus:PlayerHudStatus) -> void:
	_hudStatus.bullets = get_count("bullets")
	_hudStatus.shells = get_count("shells")
	_hudStatus.plasma = get_count("plasma")
	_hudStatus.rockets = get_count("rockets")
	_hudStatus.fuel = get_count("fuel")

	_hudStatus.bulletsPercentage = get_percentage("bullets")
	_hudStatus.shellsPercentage = get_percentage("shells")
	_hudStatus.plasmaPercentage = get_percentage("plasma")
	_hudStatus.rocketsPercentage = get_percentage("rockets")
	_hudStatus.fuelPercentage = get_percentage("fuel")
	
	_hudStatus.rage = get_count("rage")
	
	_hudStatus.hasPistol = get_count("pistol") > 0
	_hudStatus.hasSuperShotgun = get_count("super_shotgun") > 0
	_hudStatus.hasRocketLauncher = get_count("rocket_launcher") > 0
	_hudStatus.hasRailgun = get_count("plasma_gun") > 0
	_hudStatus.hasFlameThrower = get_count("flame_thrower") > 0
	
	_hudStatus.chainsawRevs = chainsawRevs

	var weap:InvWeapon = get_current_weapon()
	if weap != null:
		# print("Inventory - write weapon status")
		weap.write_hud_status(_hudStatus)
		_hudStatus.weaponChargeMode = weap.chargeUIMode
	else:
		# print("Inventory - no weapon for status")
		_hudStatus.weaponChargeMode = 0
		_hudStatus.currentLoaded = 0
		_hudStatus.currentLoadedMax = 0
		_hudStatus.currentAmmo = -1

func get_count(itemType:String) -> int:
	if itemType == "" || !_data.has(itemType):
		return -1
	return _data[itemType].count

func get_percentage(itemType:String) -> float:
	if itemType == "" || !_data.has(itemType):
		return 100.0
	var d = _data[itemType]
	return (float(d.count) / float(d.max)) * 100.0

func give_all() -> void:
	print("CHEAT - Give all")
	var keys = _data.keys()
	for key in keys:
		_data[key].count = _data[key].max
		print(key + ": " + str(_data[key].count))
	select_best_gun()

func give_all_guns() -> void:
	print("Give all guns")
	var keys = _data.keys()
	for key in keys:
		var datum = _data[key]
		if datum.type == "weapon":
			# ignore giving out debugging tools!
			if key == "debugger":
				continue
			datum.count = datum.max
		elif datum.type == "ammo":
			var amount:int = int(float(datum.max) * 0.25)
			if amount < 1:
				amount = 1
			if datum.count < amount:
				datum.count = amount
	select_best_gun()

func select_best_gun() -> void:
	if Game.debuggerOpen:
		return
	# select a gun if we didn't have one equipped
	var priority:int = -1
	var bestKey
	var keys = _data.keys()
	for key in keys:
		var datum = _data[key]
		if datum.type != "weapon":
			continue
		if datum.priority > priority:
			priority = datum.priority
			bestKey = key
	if priority == -1:
		return
	var slotNumber:int = find_weapon_slot_by_name(bestKey)
	if slotNumber != -1:
			change_weapon_by_slot(slotNumber)
#	if _currentWeaponIndex == -1:
#		var slotNumber:int = find_weapon_slot_by_name("super_shotgun")
#		if slotNumber != -1:
#			change_weapon_by_slot(slotNumber)

func give_all_ammo() -> void:
	print("Give all ammo")
	var keys = _data.keys()
	for key in keys:
		if _data[key].type == "ammo":
			_data[key].count = _data[key].max

func take_item(itemType:String, amount:int) -> int:
	if !_data.has(itemType):
		return 0
	var item:Dictionary = _data[itemType]
	var result:int
	if item.count < amount:
		result = item.count
		item.count = 0
	else:
		result = amount
		item.count -= amount
	
	if item.count == 0:
		# emit warning that item is depleted
		return -1
	return result

func _broadcast_got_item(itemType:String) -> void:
	get_tree().call_group(
		Groups.PLAYER_GROUP_NAME,
		Groups.PLAYER_FN_GOT_ITEM,
		itemType)

func give_item(itemType:String, amount:int) -> int:
	# print("Touched item " + itemType)
	
	# handle special types
	if itemType == "fullpack":
		# give_all()
		give_all_guns()
		give_all_ammo()
		_broadcast_got_item(itemType)
		return 1
	elif itemType == "gunrack":
		give_all_guns()
		_broadcast_got_item(itemType)
		return 1
	elif itemType == "ammopack":
		give_all_ammo()
		_broadcast_got_item(itemType)
		return 1
	
	# item isn't in generic list - we don't know what this item is
	if !_data.has(itemType):
		print("Inventory has no type '" + itemType + "'")
		return 0
	
	# lookup and see if we can take the item
	var item:Dictionary = _data[itemType]
	var previousCount:int = item.count
	if item.count >= item.max:
		return 0
	var capacity:int = int(abs(item.count - item.max))
	if capacity < amount:
		amount = amount - (amount - capacity)
		item.count = item.max
	else:
		item.count += amount
	if previousCount == 0:
		var slotNumber:int = find_weapon_slot_by_name(itemType)
		if slotNumber != -1:
			var result:int = change_weapon_by_slot(slotNumber)
			print("Changing to slot " + str(slotNumber) + " for weapon " + itemType + " result " + str(result))
	_broadcast_got_item(itemType)
	return amount

func debug() -> String:
	var txt:String = "--Weapons--\n"
	for _i in range(0, weapons.size()):
		var w = weapons[_i]
		txt += str(w.slot) + ": " + str(w.name) + " inv type: " + str(w.inventoryType) + "\n"
	txt += "--Inventory--\n"
	var keys = _data.keys()
	var numKeys:int = keys.size()
	for _i in range (0, numKeys):
		var item = _data[keys[_i]]
		txt += keys[_i] + ": " + str(item.count) + " of " + str(item.max) + "\n"
	return txt
