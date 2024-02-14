extends RayCast3D

var isValid:bool = false
var best:Vector3 = Vector3(0, 0, -1)

func get_debug_text() -> String:
	return ""

func _physics_process(delta) -> void:
	if self.is_colliding():
		var pos:Vector3 = self.global_position
		var candidate:Vector3 = self.get_collision_point()
		var newDistSqr:float = pos.distance_squared_to(candidate)
		var bestDistSqr:float = pos.distance_squared_to(best)
		if newDistSqr < bestDistSqr:
			best = candidate
	
	var secondsSinceLaunch:float = (float(Time.get_ticks_msec()) / 1000.0)
	var scanRateX:float = 16
	var scanRateY:float = 8
	var sx:float = sin(secondsSinceLaunch * scanRateX)
	var sy:float = sin(secondsSinceLaunch * scanRateY)
	self.rotation_degrees = Vector3(40.0 * sx, 40 * sy, 0.0)
