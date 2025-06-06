class_name MapEncoder

const sentinel = 0xBEEF

const _mapDef_t = preload("./map_def.gd")
const _mapSpawnDef_t = preload("./map_spawn_def.gd")
const _byteBuffer_t = preload("./byte_buffer.gd")

const _format:int = 1

const b64TestSmall:String = "AQAGAwIAAAACAgECAgAAAgIBAgIAAAABAAAAAgUAAg=="

static func degrees_to_byte(degrees:float) -> int:
	# cap value to within 0 - 360
	degrees = ZqfUtils.cap_degrees(degrees)
	# round to closest 2
	var val:int = int((degrees / 2) * 2)
	# divide by 2 to fit int 0 - 255
	return int(val / 2.0)

static func byte_to_degrees(val:int) -> float:
	return float(val * 2)

static func write_to_bytes(map:MapDef) -> PackedByteArray:
	var buf:ByteBuffer = _byteBuffer_t.new()
	buf.reset_cursor()

	# write header
	buf.write_int16(sentinel)
	buf.write_int16(map.format)
	buf.write_int8(map.width)
	buf.write_int8(map.height)
	buf.write_int8(map.spawns.size())

	# write grid
	# print("Writing grid size " + str(map.width) + " by " + str(map.height))
	# print("\t" + str(map.cells.size()) + " cells")
	for i in range(0, map.width * map.height):
		buf.write_int8(map.cells[i])
	
	# ent section sentinel
	buf.write_int16(sentinel)

	# write ents
	for i in range(0, map.spawns.size()):
		var spawn:MapSpawnDef = map.spawns[i]
		buf.write_int8(spawn.type)
		buf.write_int8(int(spawn.position.x))
		buf.write_int8(int(spawn.position.y))
		buf.write_int8(int(spawn.position.z))
		buf.write_int8(degrees_to_byte(spawn.yaw))

	# buf.debug_print()
	# print("As Base64: " + str(buf.to_base64()))
	var check:int = buf.calc_hash()
	print("Checksum: " + str(check))
	return buf.get_bytes()

# returns null if something went wrong
static func _read_from_bytes(bytes:PackedByteArray, msgArray) -> MapDef:
	var buf:ByteBuffer = _byteBuffer_t.new()
	buf.set_bytes(bytes)
	var check:int = buf.read_int16()
	if check != sentinel:
		msgArray.push_back("ABORT - bad header sentinel")
		return null
	
	var map:MapDef = _mapDef_t.new()
	map.format = buf.read_int16()
	if map.format != _format:
		msgArray.push_back("ABORT - bad map format " + str(map.format))
		return null
	var w = buf.read_int8()
	var h = buf.read_int8()
	var numEnts = buf.read_int8()
	# map.width = buf.read_int8()
	# map.height = buf.read_int8()
	map.set_size(w, h)
	var length:int = map.width * map.height
	msgArray.push_back("Reading " + str(length) + " cells from " + str(buf.remaining()) + " bytes")
	for _i in range(0, length):
		var cell = buf.read_int8()
		map.cells[_i] = cell
		# print(str(cell))
		#map.set_at(cell, x, y)
		# map.cells.push_back(cell)
		# print(str(map.cells.size()) + " cells")
	
	# check ent sentinel
	var entCheck:int = buf.read_int16()
	if entCheck != sentinel:
		msgArray.push_back("ABORT - bad ent sentinel")
		return null
	
	msgArray.push_back("Reading " + str(numEnts) + " ents")
	for _i in range(0, numEnts):
		var spawn:MapSpawnDef = _mapSpawnDef_t.new()
		map.spawns.push_back(spawn)
		spawn.type = buf.read_int8()
		spawn.position.x = float(buf.read_int8())
		spawn.position.y = float(buf.read_int8())
		spawn.position.z = float(buf.read_int8())
		spawn.yaw = int(byte_to_degrees(buf.read_int8()))
	
	# print("Decode result: ")
	# print(str(map.debug_print_cells()))
	return map

static func b64_to_map(b64:String, messageArray = null) -> MapDef:
	if messageArray == null:
		messageArray = []
	# messageArray.push_back("Load from b64 '" + str(b64) + "'")
	var bytes:PackedByteArray = Marshalls.base64_to_raw(b64)
	var _numBytes = bytes.size()
	messageArray.push_back("Reading " + str(_numBytes) + " bytes from " + str(b64.length()) + " chars")
	if _numBytes == 0:
		messageArray.push_back("ABORT: b64 to bytes failed")
		return null
	var map:MapDef = _read_from_bytes(bytes, messageArray)
	return map

static func map_to_b64(_map:MapDef) -> String:
	var bytes:PackedByteArray = write_to_bytes(_map)
	return Marshalls.raw_to_base64(bytes)

static func empty_map(w:int, h:int) -> MapDef:
	var map:MapDef = _mapDef_t.new()
	map.set_size(w, h)
	return map

# static func test(map:MapDef) -> void:
# 	if map == null:
# 		map = _mapDef_t.new()
# 	# map.format = 666
# 	# map.width = 511 # int(randf_range(0, 999999))
# 	# map.height = 486 # int(randf_range(0, 999999))
# 	print("Encoding map - version " + str(map.format) + " size: " + str(map.width) + ", " + str(map.height))
# 	var bytes = write_to_bytes(map)
# 	print("\tWrote " + str(bytes.size()) + " bytes")
# 	var copy:MapDef = _read_from_bytes(bytes)
# 	print("Decoded map - version " + str(copy.format) + " size: " + str(copy.width) + ", " + str(copy.height))
