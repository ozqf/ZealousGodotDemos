extends Node
class_name ZqfUtils

###########################################################
# Simple static utility functions for
# Godot

# some of this isn't strictly necessary but reminds me of
# elements of Godot's APIs
###########################################################

# empty array and dictionary to pass into things like
# raycast exclude lists etc.
const EMPTY_ARRAY = []
const EMPTY_DICT = {}
const EMPTY_STR = ""

const DEG2RAD = 0.017453292519
const RAD2DEG = 57.29577951308

const ROOT_DIR = "res://"

static func global_translate(spatial:Spatial, offset:Vector3) -> void:
	spatial.global_transform.origin += offset

static func local_translate(spatial:Spatial, offset:Vector3) -> void:
	spatial.transform.origin += offset

static func look_at_safe(spatial:Spatial, target:Vector3) -> void:
	var t:Transform = spatial.global_transform
	var origin:Vector3 = t.origin
	var up:Vector3 = t.basis.y
	var lookDir:Vector3 = (target - origin).normalized()
	var dot:float = lookDir.dot(up)
	if dot == 1 or dot == -1:
		up = t.basis.z
	# print("Look at dot: " + str(lookDir.dot(up)))
	spatial.look_at(target, up)
	pass

static func set_forward(spatial:Spatial, forward:Vector3) -> void:
	var tar:Vector3 = spatial.global_transform.origin + forward
	look_at_safe(spatial, tar)

static func is_obj_safe(obj) -> bool:
	if obj == null:
		return false
	return is_instance_valid(obj)

static func clamp_float(_value:float, _min:float, _max:float) -> float:
	if _value < _min:
		return _min
	if _value > _max:
		return _max
	return _value

#####################################
# geometry stuff
#####################################

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
	return (dp < 0)

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

static func distance_between_sqr(origin:Vector3, target:Vector3) -> float:
	var dx = target.x - origin.x
	var dy = target.y - origin.y
	var dz = target.z - origin.z
	return (dx * dx) + (dy * dy) + (dz * dz)

static func distance_between(origin:Vector3, target:Vector3) -> float:
	var dx = target.x - origin.x
	var dy = target.y - origin.y
	var dz = target.z - origin.z
	return sqrt((dx * dx) + (dy * dy) + (dz * dz))

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

# original iD tech method of calculating spread for things like shotguns
# > Take a basis and cast a line forward from it to an endpoint
# > Offset the endpoint right and up based on spread values
# > return the direction toward this new endpoint
# TODO: This function uses arbitrary units for spread as the distanced used is not scaled properly
# you'll just have to experiment to get the right spread.
static func calc_forward_spread_from_basis(
	_origin: Vector3,
	_m3x3: Basis,
	_spreadHori: float,
	_spreadVert: float) -> Vector3:
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

# weight should be between 0 and 1
static func get_turned_towards_point(t:Transform, pos:Vector3, weight:float) -> Transform:
	var towardPoint:Transform = t.looking_at(pos, Vector3.UP)
	return t.interpolate_with(towardPoint, weight)

static func turn_towards_point(spatial:Spatial, pos:Vector3, weight:float) -> void:
	var towardPoint:Transform = spatial.global_transform.looking_at(pos, Vector3.UP)
	var result:Transform = spatial.transform.interpolate_with(towardPoint, weight)
	spatial.set_transform(result)

#####################################
# misc data
#####################################

static func strNullOrEmpty(txt: String) -> bool:
	if txt == null:
		return true
	elif txt.length() == 0:
		return true
	return false

static func bits_to_string(flags:int) -> String:
	var txt = ""
	for i in range(31, -1, -1):
		if (flags & (1 << i)) != 0:
			txt += str(1)
		else:
			txt += str(0)
	return txt

static func array_add_safe(arr, item) -> void:
	var i:int = arr.find(item)
	if i == -1:
		arr.push_back(item)

static func array_remove_safe(arr, item) -> void:
	var i:int = arr.find(item)
	if i != -1:
		arr.remove(i)

static func get_window_to_screen_ratio() -> Vector2:
	var real: Vector2 = OS.get_real_window_size()
	var scr: Vector2 = OS.get_screen_size()
	var result: Vector2 = Vector2(real.x / scr.x, real.y / scr.y)
	return result

#####################################
# Serialisation
#####################################

static func v3_to_dict(v:Vector3) -> Dictionary:
	return { x = v.x, y = v.y, z = v.z }

static func v3_from_dict(dict:Dictionary) -> Vector3:
	return Vector3(dict.x, dict.y, dict.z)

static func transform_to_dict(t:Transform) -> Dictionary:
	var origin:Vector3 = t.origin
	var basis:Basis = t.basis
	return {
		px = origin.x,
		py = origin.y,
		pz = origin.z,
		xx = basis.x.x,
		xy = basis.x.y,
		xz = basis.x.z,
		yx = basis.y.x,
		yy = basis.y.y,
		yz = basis.y.z,
		zx = basis.z.x,
		zy = basis.z.y,
		zz = basis.z.z,
	}

static func transform_from_dict(dict:Dictionary) -> Transform:
	var t:Transform = Transform.IDENTITY
	t.origin.x = dict.px
	t.origin.y = dict.py
	t.origin.z = dict.pz
	
	t.basis.x.x = dict.xx
	t.basis.x.y = dict.xy
	t.basis.x.z = dict.xz

	t.basis.y.x = dict.yx
	t.basis.y.y = dict.yy
	t.basis.y.z = dict.yz

	t.basis.z.x = dict.zx
	t.basis.z.y = dict.zy
	t.basis.z.z = dict.zz
	return t

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
static func hitscan_by_direction_3D(
	_spatial:Spatial,
	_origin:Vector3,
	_forward:Vector3,
	_distance:float,
	ignoreArray,
	_mask:int) -> Dictionary:
	var _dest:Vector3 = _origin + (_forward * _distance)
	var space = _spatial.get_world().direct_space_state
	return space.intersect_ray(_origin, _dest, ignoreArray, _mask, true, true)

# simple cast a ray from the given position to the given destination.
# requires a spatial to acquire the direct space state to cast in.
static func hitscan_by_position_3D(
	_spatial:Spatial,
	_origin:Vector3,
	_dest:Vector3,
	ignoreArray,
	_mask:int) -> Dictionary:
	var space = _spatial.get_world().direct_space_state
	return space.intersect_ray(_origin, _dest, ignoreArray, _mask, true, true)

# simple cast a ray from the given spatial node. uses the node's
# own origin and forward for the ray.
static func quick_hitscan3D(
	_source:Spatial,
	_distance:float,
	ignoreArray,
	_mask:int) -> Dictionary:
	var _t:Transform = _source.global_transform
	var _origin:Vector3 = _t.origin
	var _forward:Vector3 = _t.basis.z
	var _dest:Vector3 = _origin + (_forward * -_distance)
	var space = _source.get_world().direct_space_state
	return space.intersect_ray(_origin, _dest, ignoreArray, _mask, true, true)

static func los_check(
	_spatial:Spatial,
	_origin:Vector3,
	_dest:Vector3,
	_mask:int) -> bool:
	var result = _spatial.get_world().direct_space_state.intersect_ray(
		_origin, _dest, [], _mask, true, false)
	# if we have a result, LoS is blocked
	return !result

# I guess Godot just can't do this as easily as I'd like :(
# would like a means to just quickly point test vs a collision shape
# or body...
# static func point_test(
# 	_spatial:Spatial,
# 	_poisition:Vector3) -> bool:
# 	# var result = _spatial.get_world().direct_space_state.pooint
# 	return true


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

# Split a string by spaces and tabs eg "foo bar" becomes
# ["foo", "bar"]
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
# misc
#####################################

static func does_file_exist(path:String) -> bool:
	var file = File.new()
	return file.file_exists(path)

static func does_dir_exist(path:String) -> bool:
	var dir = Directory.new()
	return dir.dir_exists(path)

static func make_dir(path:String) -> void:
	var dir = Directory.new()
	if !dir.dir_exists(path):
		dir.make_dir(path)

# if returned dictionary is falsy, the file wasn't loaded
static func load_dict_json_file(_path:String) -> Dictionary:
	var file = File.new()
	if !file.file_exists(_path):
		print("No file " + str(_path) + " to load")
		return {}
	file.open(_path, File.READ)
	var data = parse_json(file.get_as_text())
	file.close()
	return data

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
