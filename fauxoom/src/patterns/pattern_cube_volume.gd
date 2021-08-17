extends Pattern

export var count:int = 8

export var minOffset:Vector3 = Vector3()
export var maxOffset:Vector3 = Vector3()

func get_random_offset() -> Vector3:
	var v:Vector3 = Vector3()
	v.x = rand_range(minOffset.x, maxOffset.x)
	v.y = rand_range(minOffset.y, maxOffset.y)
	v.z = rand_range(minOffset.z, maxOffset.z)
	return v

func fill_items(_origin:Vector3, _forward:Vector3, _itemArray, _nextItem) -> int:
	for _i in range(0, count):
		var pos:Vector3 = _origin + get_random_offset()
		_itemArray[_nextItem].pos = pos
		_itemArray[_nextItem].forward = _forward
		_nextItem += 1
	return _nextItem
