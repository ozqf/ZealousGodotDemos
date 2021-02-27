class_name MapDef

# const _spawnDef_t = preload("./map_spawn_def.gd")

const TILE_PATH:int = 0
const TILE_WALL:int = 1
const TILE_VOID:int = 2

const NEIGHBOUR_FLAG_NORTH = (1 << 0)
const NEIGHBOUR_FLAG_SOUTH = (1 << 1)
const NEIGHBOUR_FLAG_EAST = (1 << 2)
const NEIGHBOUR_FLAG_WEST = (1 << 3)

const ENT_TYPE_NONE:int = 0
const ENT_TYPE_MOB_GRUNT:int = 1
const ENT_TYPE_START:int = 2
const ENT_TYPE_END:int = 3
const ENT_TYPE_KEY:int = 4
const ENT_TYPE_TRIGGER:int = 5
const ENT_TYPE_RELAY:int = 6
const ENT_TYPE_COUNTER:int = 7
const ENT_TYPE_GATE:int = 8
const ENT_TYPE_HORDE_SPAWN:int = 9

var format:int = 1
var name:String = "No Title"
var width:int = 32
var height:int = 32
var cells:PoolIntArray = []
var scale:int = 2
var spawns = []

func is_pos_safe(x:int, y:int) -> bool:
	return !(x < 0 || x >= width || y < 0 || y >= height)

func get_type_at(x:int, y:int) -> int:
	if !is_pos_safe(x, y):
		return -1
	return cells[x + (y * width)]

# return true if a change was applied
func set_at(val:int, x:int, y:int) -> bool:
	var i:int = x + (y * width)
	if cells[i] == val:
		return false
	cells[i] = val
	return true

func centre() -> Vector3:
	var v:Vector3 = Vector3()
	v.x = (width * scale) / 2.0
	v.y = -1
	v.z = (height * scale) / 2.0
	return v

func set_size(newWidth:int, newHeight:int) -> void:
	cells = []
	width = newWidth
	height = newHeight
	var _len = width * height
	for _i in range(0, _len):
		cells.push_back(0)

func set_all(val:int) -> void:
	for i in range(0, cells.size()):
		cells[i] = val

func count_cardinal_neighbours(x:int, y:int, queryType:int) -> int:
	var count:int = 0
	
	if get_type_at(x - 1, y) == queryType:
		count += 1
	if get_type_at(x + 1, y) == queryType:
		count += 1
	if get_type_at(x, y - 1) == queryType:
		count += 1
	if get_type_at(x, y + 1) == queryType:
		count += 1
	return count

func get_neighbour_flags(x:int, y:int, queryType:int) -> int:
	var flags:int = 0
	if get_type_at(x - 1, y) == queryType:
		flags |= NEIGHBOUR_FLAG_WEST
	if get_type_at(x + 1, y) == queryType:
		flags |= NEIGHBOUR_FLAG_EAST
	if get_type_at(x, y - 1) == queryType:
		flags |= NEIGHBOUR_FLAG_NORTH
	if get_type_at(x, y + 1) == queryType:
		flags |= NEIGHBOUR_FLAG_SOUTH
	return flags

func debug_print_cells() -> String:
	var result:String = "Map (" + str(width) + " by " + str(height) + ")\n"
	var _len = cells.size()
	result += "Cells: " + str(_len) + "\n"
	for i in range (0, _len):
		result += str(cells[i])
		if (i + 1) % width == 0:
			result += '\n'
	result += "Ents: " + str(spawns.size()) + "\n"
	for i in range (0, spawns.size()):
		var spawn:MapSpawnDef = spawns[i]
		result += "Ent type " + str(spawn.type) + " at pos " + str(spawn.position.x) + ", " + str(spawn.position.y) + "\n"
		result += "\tYaw " + str(spawn.yaw) + "\n"
	return result
