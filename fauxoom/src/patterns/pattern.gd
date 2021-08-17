extends Node
class_name Pattern

const Enums = preload("res://src/enums.gd")

# export(Enums.EnemyType) var type = Enums.EnemyType.Gunner

# export var patternType:int = 0

func fill_items(_origin:Vector3, _forward:Vector3, _itemArray, _nextItem) -> int:
	return _nextItem
