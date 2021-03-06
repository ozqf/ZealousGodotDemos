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

static func is_point_left_of_line2D(lineOrigin: Vector2, lineSize: Vector2, p: Vector2) -> bool:
	var vx: float = lineOrigin.x - p.x
	var vy: float = lineOrigin.y - p.y
	var lineNormalX: float = lineSize.y
	var lineNormalY: float = -lineSize.x
	var dp: float = dot_product(vx, vy, lineNormalX, lineNormalY)
	return (dp > 0)

static func is_point_left_of_line3D_flat(lineOrigin: Vector3, lineSize: Vector3, p: Vector3) -> bool:
	var vx: float = lineOrigin.x - p.x
	var vz: float = lineOrigin.z - p.z
	var lineNormalX: float = lineSize.z
	var lineNormalZ: float = -lineSize.x
	var dp: float = dot_product(vx, vz, lineNormalX, lineNormalZ)
	return (dp > 0)

static func yaw_to_flat_vector3(yawDegrees:float) -> Vector3:
	var radians:float = deg2rad(yawDegrees)
	return Vector3(sin(radians), 0, -cos(radians))

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

static func yaw_between(origin:Vector3, target:Vector3) -> float:
	var dx = origin.x - target.x
	var dz = origin.z - target.z
	return atan2(dx, dz)

static func flat_distance_between(origin:Vector3, target:Vector3) -> float:
	var dz = target.z - origin.z
	var dx = target.x - origin.x
	return sqrt((dx * dx) + (dz * dz))

static func cap_degrees(degrees:float) -> float:
	while degrees >= 360:
		degrees -= 360
	while degrees < 0:
		degrees += 360
	return degrees

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

static func get_window_to_screen_ratio() -> Vector2:
	var real: Vector2 = OS.get_real_window_size()
	var scr: Vector2 = OS.get_screen_size()
	var result: Vector2 = Vector2(real.x / scr.x, real.y / scr.y)
	return result

#####################################
# Spatial scan wrappers
#####################################

# result Dictionary from intersect_ray:
# position: Vector2 # point in world space for collision
# normal: Vector2 # normal in world space for collision
# collider: Object # Object collided or null (if unassociated)
# collider_id: ObjectID # Object it collided against
# rid: RID # RID it collided against
# shape: int # shape index of collider
# metadata: Variant() # metadata of collider

# simple cast a ray from the given position and forward. requires a spatial
# to acquire the direct space state to cast in.
static func hitscan_by_pos_3D(_spatial:Spatial, _origin:Vector3, _forward:Vector3, _distance:float, ignoreArray, _mask:int) -> Dictionary:
	var _dest:Vector3 = _origin + (_forward * _distance)
	var space = _spatial.get_world().direct_space_state
	return space.intersect_ray(_origin, _dest, ignoreArray, _mask, true, true)

# simple cast a ray from the given spatial node. uses the node's
# own origin and forward for the ray.
static func quick_hitscan3D(_source:Spatial, _distance:float, ignoreArray, _mask:int) -> Dictionary:
	var _t:Transform = _source.global_transform
	var _origin:Vector3 = _t.origin
	var _forward:Vector3 = _t.basis.z
	var _dest:Vector3 = _origin + (_forward * -_distance)
	var space = _source.get_world().direct_space_state
	return space.intersect_ray(_origin, _dest, ignoreArray, _mask)


###########################################################################
# Strings
###########################################################################

static func join_strings(stringArr, separator:String) -> String:
	var l:int = stringArr.size()
	var result:String = ""
	for i in range(0, l):
		result += stringArr[i]
		if i < (l - 1):
			result += separator
	return result

# TODO Maybe tidy this up... I'm not very good at writing tokenise functions...
static func tokenise(_text:String) -> PoolStringArray:
	var tokens: PoolStringArray = []
	var _len:int = _text.length()
	if _len == 0:
		return tokens
	var readingToken: bool = false
	var _charsInToken:int = 0
	var _tokenStart:int = 0
	var i:int = 0
	var finished:bool = false
	while (true):
		var c = _text[i]
		i += 1
		if i >= _len:
			finished = true
		var isWhiteSpace:bool = (c == " " || c == "\t")
		if readingToken:
			# finish token
			if isWhiteSpace || finished:
				if finished && !isWhiteSpace:
					# count this last char if we are making a token
					_charsInToken += 1
				readingToken = false
				var token:String = _text.substr(_tokenStart, _charsInToken)
				tokens.push_back(token)
			else:
				# increment token length
				_charsInToken += 1
		else:
			# eat whitespace
			if c == " " || c == "\t":
				pass
			else:
				if !finished:
					# begin a new token
					readingToken = true
					_tokenStart = i - 1
					_charsInToken = 1
				else:
					# single char token at end of line:
					var token: String = _text.substr(i -1, 1)
					tokens.push_back(token)
		if finished:
			break
	return tokens

#####################################
# 3D sprite directions
#####################################

static func angle_index(degrees:float, numIndices:int) -> int:
	# 1 indices means only one direction is defined anyway...
	if numIndices <= 1:
		return 0
	degrees -= 360.0 / (numIndices * 2)
	while (degrees < 0):
		degrees += 360
	while (degrees >= 360):
		degrees -= 360
	# flip
	degrees = 360 - degrees
	return int(floor((degrees / 360) * numIndices))

static func positions_to_sprite_degrees(camPos:Vector3, selfPos:Vector3, yawDegrees:float) -> float:
	var toDegrees:float = atan2(camPos.z - selfPos.z, camPos.x - selfPos.x)
	toDegrees = rad2deg(toDegrees)
	toDegrees += 90
	toDegrees += yawDegrees
	toDegrees = cap_degrees(toDegrees)
	return toDegrees

static func sprite_index(cam:Transform, obj:Transform, yawDegrees:float, numIndices:int) -> int:
	var camPos:Vector3 = cam.origin
	var selfPos:Vector3 = obj.origin
	var degrees:float = positions_to_sprite_degrees(camPos, selfPos, yawDegrees)
	return angle_index(degrees, numIndices)
