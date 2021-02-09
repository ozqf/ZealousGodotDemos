class_name MapDef

const _spawnDef_t = preload("./map_spawn_def.gd")

const TILE_PATH:int = 0
const TILE_WALL:int = 1
const TILE_VOID:int = 2

const ENT_TYPE_NONE:int = 0
const ENT_TYPE_MOB_GRUNT:int = 1
const ENT_TYPE_START:int = 2
const ENT_TYPE_END:int = 3
const ENT_TYPE_KEY:int = 4

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
	return cells[x + (y * width)]

# return true if a change was applied
func set_at(val:int, x:int, y:int) -> bool:
	var i:int = x + (y * width)
	if cells[i] == val:
		return false
	cells[i] = val
	return true

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

func check_all_neighbours_equal(x:int, y:int, queryType:int) -> bool:
	var count:int = 0
	
	if is_pos_safe(x - 1, y) && get_type_at(x - 1, y) == queryType:
		count += 1
	if is_pos_safe(x + 1, y) && get_type_at(x + 1, y) == queryType:
		count += 1
	if is_pos_safe(x, y - 1) && get_type_at(x, y - 1) == queryType:
		count += 1
	if is_pos_safe(x, y + 1) && get_type_at(x, y + 1) == queryType:
		count += 1
	return (count == 4)

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
