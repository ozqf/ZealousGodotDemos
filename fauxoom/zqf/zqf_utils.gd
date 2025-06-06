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

static func global_translate(spatial:Node3D, offset:Vector3) -> void:
	spatial.global_transform.origin += offset

static func local_translate(spatial:Node3D, offset:Vector3) -> void:
	spatial.transform.origin += offset

static func look_at_safe(spatial:Node3D, target:Vector3) -> void:
	var t:Transform3D = spatial.global_transform
	var origin:Vector3 = t.origin
	var up:Vector3 = t.basis.y
	var lookDir:Vector3 = (target - origin).normalized()
	var dot:float = lookDir.dot(up)
	if dot == 1 or dot == -1:
		up = t.basis.z
	# print("Look at dot: " + str(lookDir.dot(up)))
	spatial.look_at(target, up)
	pass

static func set_forward(spatial:Node3D, forward:Vector3) -> void:
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

static func clamp_int(_value:int, _min:int, _max:int) -> int:
	if _value < _min:
		return _min
	if _value > _max:
		return _max
	return _value

static func play_3d(audio: AudioStreamPlayer3D, stream:AudioStream, pitchAlt:float = 0.0, plusDb:float = 0.0) -> void:
	audio.pitch_scale = randf_range(1 - pitchAlt, 1 + pitchAlt)
	audio.unit_db = plusDb
	audio.set_attenuation_model(AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE)
	audio.stream = stream
	audio.play(0)

static func count_bits_set(i:int) -> int:
	# https://stackoverflow.com/questions/109023/how-to-count-the-number-of-set-bits-in-a-32-bit-integer
	i = i - ((i >> 1) & 0x55555555);        # add pairs of bits
	i = (i & 0x33333333) + ((i >> 2) & 0x33333333);  # quads
	i = (i + (i >> 4)) & 0x0F0F0F0F;        # groups of 8
	return (i * 0x01010101) >> 24;          # horizontal sum of bytes

#####################################
# geometry stuff
#####################################

static func snap_f(val:float, stepSize:float) -> float:
	return (round(val / stepSize)) * stepSize

static func snap_v3(pos:Vector3, stepSize:float) -> Vector3:
	pos.x = (round(pos.x / stepSize)) * stepSize
	pos.y = (round(pos.y / stepSize)) * stepSize
	pos.z = (round(pos.z / stepSize)) * stepSize
	return pos

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
	var radians:float = deg_to_rad(yawDegrees)
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

static func flat_distance_sqr(origin:Vector3, target:Vector3) -> float:
	target.y = origin.y
	return origin.distance_squared_to(target)

static func cap_degrees_2(degrees:float) -> float:
	while degrees >= 360:
		degrees -= 360
	while degrees < 0:
		degrees += 360
	return degrees

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
static func get_turned_towards_point(t:Transform3D, pos:Vector3, weight:float) -> Transform3D:
	var towardPoint:Transform3D = t.looking_at(pos, Vector3.UP)
	return t.interpolate_with(towardPoint, weight)

static func turn_towards_point(spatial:Node3D, pos:Vector3, weight:float) -> void:
	var towardPoint:Transform3D = spatial.global_transform.looking_at(pos, Vector3.UP)
	var result:Transform3D = spatial.transform.interpolate_with(towardPoint, weight)
	spatial.set_transform(result)

#####################################
# spatial nodes
#####################################

# static func dynamic_attach(child:Node3D, parent:Node3D, exitTreeCallback:String = ""):
# 	pass

#####################################
# misc data
#####################################

static func pool_string_find(strings:PackedStringArray, query:String) -> int:
	var l:int = strings.size()
	for i in range(0, l):
		if strings[i] == query:
			return i
	return -1

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

static func parse_bool(value) -> bool:
	if value is bool:
		return value
	var txt:String = str(value)
	txt = txt.to_lower()
	if txt == null || txt == "" || txt == "false" || txt == "f":
		return false
	return true

static func array_add_safe(arr, item) -> void:
	var i:int = arr.find(item)
	if i == -1:
		arr.push_back(item)

static func array_remove_safe(arr, item) -> void:
	var i:int = arr.find(item)
	if i != -1:
		arr.remove(i)

static func read_csv_int(csv:String, index:int, failure:int) -> int:
	if csv == null || csv == "":
		return failure
	var split = csv.split(",", false)
	var last:int = split.size() - 1
	if index > last:
		index = last
	return int(split[index])

static func time_string_from_seconds(totalSeconds:float) -> String:
	var minutes:int = int(totalSeconds / 60.0)
	var seconds:int = int(totalSeconds) % 60
	var timeStr:String
	if seconds < 10:
		timeStr = str(minutes) + ":0" + str(seconds)
	else:
		timeStr = str(minutes) + ":" + str(seconds)
	return timeStr

#####################################
# Serialisation
#####################################

static func v3_to_dict(v:Vector3) -> Dictionary:
	return { x = v.x, y = v.y, z = v.z }

static func v3_from_dict(dict:Dictionary) -> Vector3:
	return Vector3(dict.x, dict.y, dict.z)

static func transform_to_dict(t:Transform3D) -> Dictionary:
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

static func transform_from_dict(dict:Dictionary) -> Transform3D:
	var t:Transform3D = Transform3D.IDENTITY
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

static func safe_dict_i(d:Dictionary, field:String, fail:int) -> int:
	if d.has(field):
		return d[field] as int
	return fail

static func safe_dict_f(d:Dictionary, field:String, fail:float) -> float:
	if d.has(field):
		return d[field] as float
	return fail

static func safe_dict_s(d:Dictionary, field:String, fail:String) -> String:
	if d.has(field):
		return d[field] as String
	return fail

static func safe_dict_b(d:Dictionary, field:String, fail:bool) -> bool:
	if d.has(field):
		return parse_bool(d[field])
	return fail

static func safe_dict_v3(d:Dictionary, field:String, fail:Vector3) -> Vector3:
	if d.has(field):
		return v3_from_dict(d[field])
	return fail

static func safe_dict_transform(d:Dictionary, field:String, fail:Transform3D) -> Transform3D:
	if d.has(field):
		return transform_from_dict(d[field])
	return fail

static func safe_dict_apply_transform(d:Dictionary, field:String, target:Node3D) -> void:
	if d.has(field):
		target.global_transform = transform_from_dict(d[field])

#####################################
#Node3D scan wrappers
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
	_spatial:Node3D,
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
	_spatial:Node3D,
	_origin:Vector3,
	_dest:Vector3,
	ignoreArray,
	_mask:int) -> Dictionary:
	var space = _spatial.get_world().direct_space_state
	return space.intersect_ray(_origin, _dest, ignoreArray, _mask, true, true)

# simple cast a ray from the given spatial node. uses the node's
# own origin and forward for the ray.
static func quick_hitscan3D(
	_source:Node3D,
	_distance:float,
	ignoreArray,
	_mask:int) -> Dictionary:
	var _t:Transform3D = _source.global_transform
	var _origin:Vector3 = _t.origin
	var _forward:Vector3 = _t.basis.z
	var _dest:Vector3 = _origin + (_forward * -_distance)
	var space = _source.get_world().direct_space_state
	return space.intersect_ray(_origin, _dest, ignoreArray, _mask, true, true)

static func los_check(
	_spatial:Node3D,
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
static func quick_point_test(_source:Node3D, point:Vector3, ignoreArray, mask:int) -> Array:
	var space = _source.get_world().direct_space_state
	# doesn't exist :(
	return space.intersect_point(point, 32, ignoreArray, mask, true, true)


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
# TODO add support for quotes.
static func tokenise(_text:String, quoteChar:String = "\"") -> PackedStringArray:
	var tokens: PackedStringArray = []
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
# files
#####################################

static func append_extension(fileName:String, extension:String) -> String:
	if fileName.ends_with(extension):
		return fileName
	if !extension.begins_with("."):
		extension = "." + extension
	return fileName + extension

static func does_file_exist(path:String) -> bool:
	return FileAccess.file_exists(path)

static func does_dir_exist(path:String) -> bool:
	return DirAccess.dir_exists_absolute(path)

static func make_dir(path:String) -> void:
	if !DirAccess.dir_exists_absolute(path):
		DirAccess.make_dir_absolute(path)

static func find_all_files_with_extension(path:String, results:Dictionary, extension:String) -> void:
	if path.begins_with('res:///.'):
		return
	#print("Searching path " + path)
	var files:PackedStringArray = DirAccess.get_files_at(path)
	var dirs:PackedStringArray = DirAccess.get_directories_at(path)
	for fileName in files:
		#print("\tFile " + fileName)
		if fileName.ends_with(extension):
			results[path + "/" + fileName] = 0
	for dir in dirs:
		find_all_files_with_extension(path + "/" + dir, results, extension)

static func get_files_in_directory(path:String, extension:String) -> PackedStringArray:
	var files:PackedStringArray = PackedStringArray()
	var paths:PackedStringArray = DirAccess.get_files_at(path)
	for file in paths:
		if file == "":
			break;
		if file == "." || file == "..":
			continue;
		if !file.ends_with(extension):
			continue;
		files.push_back(file)
	return files

static func get_directories_at(path:String) -> PackedStringArray:
	return DirAccess.get_directories_at(path)

static func dict_to_json(_dict:Dictionary) -> String:
	return JSON.stringify(_dict)
#	var j:JSON = JSON.new()
#	return j.stringify(_dict)

static func load_file_text(_path:String) -> String:
	if !FileAccess.file_exists(_path):
		print("No file " + str(_path) + " to load")
		return ""
	var file = FileAccess.open(_path, FileAccess.READ)
	var txt:String = file.get_as_text()
	file.close()
	return txt

static func write_file_text(_path:String, text:String) -> int:
	var file = FileAccess.open(_path, FileAccess.WRITE)
	if file == null:
		return 1
	file.store_string(text)
	file.close()
	return 0

static func load_from_json(json:String) -> Variant:
	if json == null || json == "":
		return null
	var j:JSON = JSON.new()
	var error = j.parse(json)
	if error == OK:
		var data = j.get_data()
		return data
	else:
		return null

static func load_dict_from_json(json:String) -> Dictionary:
	if json == null || json == "":
		return {}
	var j:JSON = JSON.new()
	var error = j.parse(json)
	if error == OK:
		var data = j.get_data()
		if typeof(data) != TYPE_DICTIONARY:
			#print("Expected a dictionary from json" + str(_path))
			return {}
		return data as Dictionary
	else:
		return {}

# if returned dictionary is falsy, the file wasn't loaded
static func load_dict_json_file(_path:String) -> Dictionary:
	var json:String = load_file_text(_path)
	if json == "":
		return {}
	return load_dict_from_json(json)
	# if !FileAccess.file_exists(_path):
	# 	print("No file " + str(_path) + " to load")
	# 	return {}
	# var file = FileAccess.open(_path, FileAccess.READ)
	# var j:JSON = JSON.new()
	# var error = j.parse(file.get_as_text())
	# if error == OK:
	# 	var data = j.get_data()
	# 	if typeof(data) != TYPE_DICTIONARY:
	# 		print("Expected a dictionary from json" + str(_path))
	# 		return {}
	# 	return data as Dictionary
	# else:
	# 	return {}

static func write_dict_json_file(_folder:String, _fileName:String, _dict:Dictionary) -> String:
	make_dir(_folder)
	var path:String = _folder + _fileName
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return "Write dict json error opening " + path
	var json:String = JSON.stringify(_dict)
	file.store_string(json)
	return ""

static func write_dict_json_to_path(path:String, _dict:Dictionary) -> String:
	make_dir(path.get_base_dir())
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return "Write dict json error opening " + path
	var json:String = JSON.stringify(_dict)
	file.store_string(json)
	return ""

static func write_string_to_file(_folder:String, _fileName:String, _data:String) -> String:
	make_dir(_folder)
	var path:String = _folder + _fileName
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return "Write string error opening " + path
	file.store_string(_data)
	return ""

static func write_string_to_path(path:String, _data:String) -> String:
	make_dir(path.get_base_dir())
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return "Write string error opening " + path
	file.store_string(_data)
	return ""

#####################################
# system
#####################################

static func is_running_in_editor() -> bool:
	return !OS.has_feature("standalone")

static func is_web_build() -> bool:
	return OS.get_name() == "HTML5"

static func get_window_to_screen_ratio(windowIndex:int = 0) -> Vector2:
	var screen: Vector2 = DisplayServer.screen_get_size()
	var window: Vector2 = DisplayServer.window_get_size(windowIndex)
	var result: Vector2 = Vector2(window.x / screen.x, window.y / screen.y)
	return result

static func set_target_fps(target:int) -> void:
	Engine.max_fps = target

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
	toDegrees = rad_to_deg(toDegrees)
	toDegrees += 90
	toDegrees += yawDegrees
	# toDegrees = cap_degrees(toDegrees)
	return toDegrees

static func sprite_index(cam:Transform3D, obj:Transform3D, yawDegrees:float, numIndices:int) -> int:
	var camPos:Vector3 = cam.origin
	var selfPos:Vector3 = obj.origin
	var degrees:float = positions_to_sprite_degrees(camPos, selfPos, yawDegrees)
	return angle_index(degrees, numIndices)
