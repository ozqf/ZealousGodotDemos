extends Node
class_name Inventory

var _data:Dictionary = {
	pistol = { count = 1, max = 2 },
	super_shotgun = { count = 0, max = 1 },
	bullets = { count = 100, max = 300 },
	shells = { count = 0, max = 50 }
}

func append_state(_dict:Dictionary) -> void:
	_dict["inventory"] = _data.duplicate(true)

func restore_state(_dict:Dictionary) -> void:
	if "inventory" in _data:
		_data = _dict.inventory.duplicate()

func get_count(itemType:String) -> int:
	if !_data.has(itemType):
		return 0
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
