class_name ZqfUtils

static func calc_fan_yaw(spreadDegrees:float, prjIndex:int, prjTotal:int) -> float:
	if spreadDegrees == 0.0 || prjTotal < 2:
		return 0.0
	#-(arc * 0.5) + ((arc / (total - 1) * i))
	var result:float = -(spreadDegrees * 0.5) + ((spreadDegrees / (prjTotal - 1)) * prjIndex)
	return result
