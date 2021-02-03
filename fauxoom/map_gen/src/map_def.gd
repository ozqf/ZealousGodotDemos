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

var name:String = "No Title"
var width:int = 32
var height:int = 32
var cells:PoolIntArray = []
var tileDiameter:int = 2
var spawns = []

func is_pos_safe(x:int, y:int) -> bool:
	return (x < 0 || x >= width || y < 0 || y >= height)

func get_type_at(x:int, y:int) -> int:
	return cells[x + (y * width)]

func check_all_neighbours_equal(x:int, y:int, queryType:int) -> bool:
	var count:int = 0
	#var queryX:int
	#var queryY:int
	
	if is_pos_safe(x - 1, y) && get_type_at(x - 1, y) == queryType:
		count += 1
	if is_pos_safe(x + 1, y) && get_type_at(x + 1, y) == queryType:
		count += 1
	if is_pos_safe(x, y - 1) && get_type_at(x, y - 1) == queryType:
		count += 1
	if is_pos_safe(x, y + 1) && get_type_at(x, y + 1) == queryType:
		count += 1
	#print("count " + str(count) + " vs " + str(x) + ", " + str(y) + " w/h " + str(width) + ", " + str(height))
	return (count == 4)
	
func debug_print_cells() -> String:
	var result:String = "Map (" + str(width) + " by " + str(height) + ")"
	result += " ents: " + str(spawns.size()) + "\n"
	var _len = cells.size()
	for i in range (0, _len):
		result += str(cells[i])
		if (i + 1) % width == 0:
			result += '\n'
	for i in range (0, spawns.size()):
		var spawn:MapSpawnDef = spawns[i]
		result += "Ent type " + str(spawn.type) + " at pos " + str(spawn.position.x) + ", " + str(spawn.position.y) + "\n"
	return result
