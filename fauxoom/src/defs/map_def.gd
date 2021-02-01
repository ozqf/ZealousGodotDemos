class_name MapDef


const TILE_PATH:int = 0
const TILE_WALL:int = 1
const TILE_VOID:int = 2

const ENT_TYPE_NONE:int = 0
const ENT_TYPE_MOB_GRUNT:int = 1
const ENT_TYPE_START:int = 2
const ENT_TYPE_END:int = 3
const ENT_TYPE_KEY:int = 4

var name:String = "No Title"
var width:int = 32
var height:int = 32
var _cells:PoolIntArray = []

func is_pos_safe(x:int, y:int) -> bool:
	return (x < 0 || x >= width || y < 0 || y >= height)

func get_type_at(x:int, y:int) -> int:
	return _cells[x + (y * width)]

func _char_to_tile_type(c:String) -> int:
	if c == '#':
		return TILE_WALL
	elif c == '.':
		return TILE_VOID
	else:
		return TILE_PATH

func _char_to_ent(c:String, x:int, y:int) -> int:
	if c == 'x':
		print("Spawn mob at " + str(x) + ", " + str(y))
		return ENT_TYPE_MOB_GRUNT
	elif c == 's':
		return ENT_TYPE_START
	elif c == 'e':
		return ENT_TYPE_END
	elif c == 'k':
		return ENT_TYPE_KEY
	
	return ENT_TYPE_NONE
	

func debug_print_cells() -> String:
	var result:String = ""
	var _len = _cells.size()
	for i in range (0, _len):
		result += str(_cells[i])
		if (i + 1) % width == 0:
			result += '\n'
	return result

func load_from_asci(txt:String) -> bool:
	txt = txt.replace("\r", "")
	print("Load test map from asci")
	print(txt)
	var lines:PoolStringArray = txt.split("\n", false)
	# \n will break up each row, but assume row widths might be
	# different and should be measured
	var longest:int = 0
	for i in range(0, lines.size()):
		var length = lines[i].length()
		if length > longest:
			longest = length
	if longest == 0 || lines.size() == 0:
		print("Read 0 width or height from map asci")
		return false
	width = longest
	height = lines.size()
	var _newCells:PoolIntArray = []
	for y in range(0, lines.size()):
		var line = lines[y]
		for x in range(0, line.length()):
			var c:String = line[x]
			var tileType:int = _char_to_tile_type(c)
			_newCells.push_back(tileType)
			_char_to_ent(c, x, y)
		var pad:int = longest - line.length()
		for _i in range(0, pad):
			_newCells.push_back(TILE_WALL)
	_cells = _newCells
	return true
