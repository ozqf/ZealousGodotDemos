extends Node
class_name ZqfUtils

#####################################
# Simple static utility functions for
# Godot
#####################################

const DEG2RAD = 0.017453292519
const RAD2DEG = 57.29577951308

static func dot_product(x0: float, y0: float, x1: float, y1: float):
	return x0 * x1 + y0 * y1

static func is_point_left_of_line2D(lineOrigin: Vector2, lineSize: Vector2, p: Vector2):
	var vx: float = lineOrigin.x - p.x
	var vy: float = lineOrigin.y - p.y
	var lineNormalX: float = lineSize.y
	var lineNormalY: float = -lineSize.x
	var dp: float = dot_product(vx, vy, lineNormalX, lineNormalY)
	return (dp > 0)

# Only does Pitch and Yaw
static func calc_euler_degrees(v: Vector3) -> Vector3:
	# yaw
	var yawRadians = atan2(-v.x, -v.z)
	# pitch
	var flat = Vector3(v.x, 0, v.z)
	var flatMagnitude = flat.length()
	var pitchRadians = atan2(v.y, flatMagnitude)
	var result = Vector3(pitchRadians * RAD2DEG, yawRadians * RAD2DEG, 0)
	return result

# > Take a basis and cast a line forward from it to an endpoint
# > Offset the endpoint right and up based on spread values
# > return the direction toward this new endpoint
# TODO: This function uses arbitrary units for spread as the distanced used is not scaled properly
static func calc_forward_spread_from_basis(_origin: Vector3, _m3x3: Basis, _spreadHori: float, _spreadVert: float) -> Vector3:
	var forward: Vector3 = _m3x3.z
	var up: Vector3 = _m3x3.y
	var right: Vector3 = _m3x3.x
	# TODO: Magic value 8192 means spread values are not proper units like degrees
	var end: Vector3 = VectorMA(_origin, 8192, -forward)
	end = VectorMA(end, _spreadHori, right)
	end = VectorMA(end, _spreadVert, up)
	return (end - _origin).normalized()

static func VectorMA(start: Vector3, scale: float, dir:Vector3) -> Vector3:
	var dest: Vector3 = Vector3()
	dest.x = start.x + dir.x * scale
	dest.y = start.y + dir.y * scale
	dest.z = start.z + dir.z * scale
	return dest

static func strNullOrEmpty(txt: String) -> bool:
	if txt == null:
		return true
	elif txt.length() == 0:
		return true
	return false

func get_window_to_screen_ratio() -> Vector2:
	var real: Vector2 = OS.get_real_window_size()
	var scr: Vector2 = OS.get_screen_size()
	var result: Vector2 = Vector2(real.x / scr.x, real.y / scr.y)
	return result

#####################################
# Spatial scan wrappers
#####################################
static func hitscan_by_pos_3D(_spatial:Spatial, _origin:Vector3, _forward:Vector3, _distance:float, ignoreArray, _mask:int) -> Dictionary:
	var _dest:Vector3 = _origin + (_forward * _distance)
	var space = _spatial.get_world().direct_space_state
	#print("Shoot origin " + str(_origin) + " dest " + str(_dest))
	return space.intersect_ray(_origin, _dest, ignoreArray, _mask)

static func quick_hitscan3D(_source:Spatial, _distance:float, ignoreArray, _mask:int) -> Dictionary:
	var _t:Transform = _source.global_transform
	var _origin:Vector3 = _t.origin
	var _forward:Vector3 = _t.basis.z
	var _dest:Vector3 = _origin + (_forward * -_distance)
	#print("Shoot origin " + str(_origin) + " dest " + str(_dest))
	var space = _source.get_world().direct_space_state
	return space.intersect_ray(_origin, _dest, ignoreArray, _mask)