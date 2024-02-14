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
	var scanRate:float = 32
	var s:float = sin(secondsSinceLaunch * scanRate)
	self.rotation_degrees = Vector3(25.0 * s, 0.0, 0.0)
