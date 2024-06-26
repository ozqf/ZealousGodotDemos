class_name AITickInfo

var id:int = 0

var selfPos:Vector3 = Vector3()
var targetPos:Vector3 = Vector3()
var lastSeenTargetPos:Vector3 = Vector3()
var targetForward:Vector3 = Vector3()
var flatForward:Vector3 = Vector3()
var flatVelocity:Vector3 = Vector3()
var targetYaw:float = 0
var targetGrounded:bool = true

var canSeeTarget:bool = false
var timeSinceLastSight:float = 0
var trueDistanceSqr:float = 0
var flatDistanceSqr:float = 0

var moveThinkTick:float = 0

var healthPercentage:float = 100

var verbose:bool = true

func clear() -> void:
	id = 0

func valid() -> bool:
	return id != 0
