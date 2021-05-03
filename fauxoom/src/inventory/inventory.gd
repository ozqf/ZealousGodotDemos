extends Node
# sigh... really waiting for Godot 4 and I can have two classes reference each other...
# in this case, Inventory <-> InvWeapon
# class_name Inventory
signal weapon_changed(newWeapon, oldWeapon)

var _data:Dictionary = {
	chainsaw = { count = 0, max = 1 },
	pistol = { count = 1, max = 2 },
	super_shotgun = { count = 0, max = 1 },
	rocket_launcher = { count = 0, max = 1 },

	bullets = { count = 100, max = 300 },
	shells = { count = 0, max = 50 },
	rockets = { count = 0, max = 50 }
}

var weapons = []
var _currentWeaponIndex:int = -1
var offhand:InvWeapon = null
# var _currentWeapon:InvWeapon = null

func custom_init(launchNode:Spatial, ignoreBody:PhysicsBody, hud) -> void:
	# gather weapons
	var children = $weapons.get_children()
	for child in children:
		if !(child is InvWeapon):
			continue
		
		if child.name == "offhand":
			offhand = child
		else:
			weapons.push_back(child)
		child.custom_init(self, launchNode, ignoreBody, hud)
		# if _currentWeapon == null:
		# 	set_current_weapon(child)
	print("Inventory found " + str(weapons.size()) + " weapons")
	select_first_weapon()

func append_state(_dict:Dictionary) -> void:
	_dict["inventory"] = _data.duplicate(true)

func restore_state(_dict:Dictionary) -> void:
	if "inventory" in _data:
		_data = _dict.inventory.duplicate()

func set_current_weapon(index:int) -> void:
	if index == _currentWeaponIndex:
		return
	print("Set weapon index from " + str(_currentWeaponIndex) + " to " + str(index))
	var prevWeap = null
	if _currentWeaponIndex >= 0:
		prevWeap = weapons[_currentWeaponIndex]
		prevWeap.deequip()
	_currentWeaponIndex = index
	var newWeap = null
	if _currentWeaponIndex >= 0:
		newWeap = weapons[_currentWeaponIndex]
		newWeap.equip()
	self.emit_signal("weapon_changed", newWeap, prevWeap)

# find the first selectable weapon and equip it
func select_first_weapon() -> void:
	var numWeapons:int = weapons.size()
	for i in range(0, numWeapons):
		var weap = weapons[i]
		if weap.can_equip():
			set_current_weapon(i)
			return

func get_current_weapon() -> InvWeapon:
	if _currentWeaponIndex < 0:
		return null
	return weapons[_currentWeaponIndex]

# returns 1 if weapon was successfully changed
# returns 0 if weapon change is currently blocked
# returns -1 if no weapon was found
func change_weapon_by_slot(_slotNumber:int) -> int:
	# slots are 1 and up only
	if _slotNumber <= 0:
		return -1
	var numWeapons:int = weapons.size()
	var i:int = 0
	var current = get_current_weapon()
	if current.is_cycling():
		return 0
	# if current weapon is the same slot number, select
	# from that index onward to cycle through items in that slot
	if current != null:
		if _slotNumber == current.slot:
			i = i + 1
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
			print("Select by slot ran away!")
			return -1
	if result != _currentWeaponIndex:
		set_current_weapon(result)
	return 1

func get_count(itemType:String) -> int:
	if itemType == "" || !_data.has(itemType):
		return -1
	return _data[itemType].count

func give_all() -> void:
	print("Give all")
	var keys = _data.keys()
	for key in keys:
		_data[key].count = _data[key].max
		print(key + ": " + str(_data[key].count))

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
		pass
	return result

func give_item(itemType:String, amount:int) -> int:
	if !_data.has(itemType):
		return 0
	var item:Dictionary = _data[itemType]
	if item.count >= item.max:
		return 0
	var capacity:int = int(abs(item.count - item.max))
	if capacity < amount:
		amount = amount - (amount - capacity)
		item.count = item.max
		return amount
	else:
		item.count += amount
		return amount

func debug() -> String:
	var txt:String = "--Inventory--\n"
	var keys = _data.keys()
	var numKeys:int = keys.size()
	for _i in range (0, numKeys):
		var item = _data[keys[_i]]
		txt += keys[_i] + ": " + str(item.count) + " of " + str(item.max) + "\n"
	return txt
