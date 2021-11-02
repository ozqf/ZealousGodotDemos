class_name NavAgent

var position:Vector3 = Vector3()
var objectiveNode = null
var fallbackNode = null
var target:Vector3 = Vector3()
var hasPath:bool = false
# var nodeIndex:int = -1
var path:PoolVector3Array = []
var pathNumNodes:int = 0
var pathIndex:int = -1
