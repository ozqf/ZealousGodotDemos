extends Node
class_name Inventory

var _data:Dictionary = {
	super_shotgun = {
		count = 0,
		max = 1
	},
	bullets = {
		count = 100,
		max = 300
	},
	shells = {
		count = 0,
		max = 50
	}
}

func get_count(itemType:String) -> int:
	return _data[itemType].count

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
