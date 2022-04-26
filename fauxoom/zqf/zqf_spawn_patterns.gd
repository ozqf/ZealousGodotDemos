extends Node
class_name ZqfSpawnPatterns

static func build_cone_offsets(radius:float, count:int):
	var step:float = 360.0 / float(count)
	var degrees:float = 0.0
	var results = []
	for _i in range(0, count):
		var x:float = cos(deg2rad(degrees))
		var y:float = sin(deg2rad(degrees))
		results.push_back([ x * radius, y * radius ])
		degrees += step
	return results
