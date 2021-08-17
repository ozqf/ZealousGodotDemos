extends Node
class_name Pattern

export var patternType:int = 0
export var count:int = 5
export var arcX:float = 0
export var arcY:float = 0

export var minOffset:Vector3 = Vector3()
export var maxOffset:Vector3 = Vector3()

func get_random_offset() -> Vector3:
    var v:Vector3 = Vector3()
    v.x = rand_range(minOffset.x, maxOffset.x)
    v.y = rand_range(minOffset.y, maxOffset.y)
    v.z = rand_range(minOffset.z, maxOffset.z)
    return v
