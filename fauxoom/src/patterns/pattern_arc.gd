extends Pattern

onready var _childPattern:Pattern = null

export var count:int = 3
export var arcDegreesX:float = 90.0

func _ready() -> void:
	_childPattern = get_node_or_null("pattern")

func fill_items(_origin:Vector3, _forward:Vector3, _itemArray, _nextItem) -> int:
	if count <= 1:
		return _nextItem
	var radians:float = atan2(_forward.x, _forward.z)
	var degrees:float = rad2deg(radians)
	var halfArcDegrees:float = arcDegreesX / 2.0
	var startDegrees:float = -halfArcDegrees
	var stepDegrees:float = arcDegreesX / (count - 1)

	for _i in range(0, count):
		var offsetradians:float = deg2rad(startDegrees)
		startDegrees += stepDegrees
		var newForward:Vector3 = Vector3()
		newForward.x = sin(radians + offsetradians)
		newForward.y = 0
		newForward.z = cos(radians + offsetradians)
		if _childPattern == null:
			var item:Dictionary = _itemArray[_nextItem]
			item.pos = _origin
			item.forward = newForward
			_nextItem += 1
		else:
			_nextItem = _childPattern.fill_items(_origin, newForward, _itemArray, _nextItem)
	return _nextItem
