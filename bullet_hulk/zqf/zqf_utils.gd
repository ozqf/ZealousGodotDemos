class_name ZqfUtils

# empty array and dictionary to pass into things like
# raycast exclude lists etc.
const EMPTY_ARRAY = []
const EMPTY_DICT = {}
const EMPTY_STR = ""

const EMPTY_GUID:String = "00000000-0000-0000-0000-000000000000"

const DEG2RAD = 0.017453292519
const RAD2DEG = 57.29577951308

static func calc_fan_yaw(spreadDegrees:float, prjIndex:int, prjTotal:int) -> float:
	if spreadDegrees == 0.0 || prjTotal < 2:
		return 0.0
	#-(arc * 0.5) + ((arc / (total - 1) * i))
	var result:float = -(spreadDegrees * 0.5) + ((spreadDegrees / (prjTotal - 1)) * prjIndex)
	return result

static func yaw_between(origin:Vector3, target:Vector3) -> float:
	var dx = origin.x - target.x
	var dz = origin.z - target.z
	return atan2(dx, dz)
