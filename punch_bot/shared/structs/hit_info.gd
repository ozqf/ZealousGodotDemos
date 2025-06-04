class_name HitInfo

const FLAG_VERTICAL_LAUNCHER:int = (1 << 0)
const FLAG_HORIZONTAL_LAUNCHER:int = (1 << 1)
const FLAG_VERTICAL_SLAM:int = (1 << 2)
const FLAG_GUARD_BREAKER:int = (1 << 3)

var teamId:int = 0
var damage:int = 15
var parryDamage:int = 0
var guardDamage:int = 0
var category:int = 0

var attackId:String = ""

var direction:Vector3 = Vector3()
var hitPosition:Vector3 = Vector3()
var flags:int = 0

#var lastResponse:int = 0
var lastInflicted:int = 0
