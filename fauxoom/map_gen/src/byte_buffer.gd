class_name ByteBuffer

const FOUR_BIT_MASK:int = 15

static func read_byte_top(val:int) -> int:
	var mask:int = (FOUR_BIT_MASK << 4)
	return (val & mask) >> 4

static func read_byte_bottom(val:int) -> int:
	return val & FOUR_BIT_MASK

static func calc_byte_checksum(bytes:PoolByteArray, numBytes:int) -> int:
	if numBytes <= 0 || numBytes > bytes.size():
		numBytes = bytes.size()
	var result:int = 5381
	for i in range(0, bytes.size()):
		var _b = bytes[i]
		result = ((result << 5) + result) + _b
	return result

var _bytes:PoolByteArray = []
var _cursor:int = 0

func calc_hash() -> int:
	return calc_byte_checksum(_bytes, 0)

func set_bytes(bytes:PoolByteArray) -> void:
	_bytes = bytes
	reset_cursor()

func remaining() -> int:
	return _bytes.size() - _cursor

func get_bytes() -> PoolByteArray:
	return _bytes

func reset_cursor() -> void:
	_cursor = 0

func read_int8() -> int:
	var val:int = 0
	val = val | (_bytes[_cursor] << 0)
	_cursor += 1
	return val

func read_int16() -> int:
	var val:int = 0
	val = val | (_bytes[_cursor] << 0)
	_cursor += 1
	val = val | (_bytes[_cursor] << 8)
	_cursor += 1
	return val

func read_int32() -> int:
	var val:int = 0
	val = val | (_bytes[_cursor] << 0)
	_cursor += 1
	val = val | (_bytes[_cursor] << 8)
	_cursor += 1
	val = val | (_bytes[_cursor] << 16)
	_cursor += 1
	val = val | (_bytes[_cursor] << 24)
	_cursor += 1
	return val

func write_int8(val:int) -> void:
	_bytes.push_back((val & (255 << 0)) >> 0)
	_cursor += 1

func write_int16(val:int) -> void:
	_bytes.push_back((val & (255 << 0)) >> 0)
	_bytes.push_back((val & 255 << 8) >> 8)
	_cursor += 2

func write_int32(val:int) -> void:
	_bytes.push_back((val & (255 << 0)) >> 0)
	_bytes.push_back((val & (255 << 8)) >> 8)
	_bytes.push_back((val & (255 << 16)) >> 16)
	_bytes.push_back((val & (255 << 32)) >> 24)
	_cursor += 4

func debug_print() -> void:
	var length:int = _bytes.size()
	print(str(length))
	var txt:String = ""
	for i in range(0, length):
		txt += str(_bytes[i]) + ", "
	print(txt)

func to_base64() -> String:
	return Marshalls.raw_to_base64(_bytes)
