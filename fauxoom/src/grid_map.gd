extends Spatial

var _prefab_ground = preload("res://prefabs/grid_map/ground_tile.tscn")
var _prefab_wall = preload("res://prefabs/grid_map/wall_tile.tscn")

func _pos_is_safe(x:int, y:int, width:int, height:int) -> bool:
	if x < 0 || x >= width:
		return false
	if y < 0 || y >= height:
		return false
	return true

func _check_all_neighbours_equal(lines, x:int, y:int, width:int, height:int, chr) -> bool:
	var count:int = 0
	#var queryX:int
	#var queryY:int
	if _pos_is_safe(x - 1, y, width, height) && lines[y][x - 1] == chr:
		count += 1
	if _pos_is_safe(x + 1, y, width, height) && lines[y][x + 1] == chr:
		count += 1
	if _pos_is_safe(x, y - 1, width, height) && lines[y - 1][x] == chr:
		count += 1
	if _pos_is_safe(x, y + 1, width, height) && lines[y + 1][x] == chr:
		count += 1
	print("count " + str(count) + " vs " + str(x) + ", " + str(y) + " w/h " + str(width) + ", " + str(height))
	return (count == 4)

func _ready():
	var y:float = -1
	var posOffset:Vector3 = Vector3(0.5, 0, 0.5)
	var map:Dictionary = AsciMapLoader.read_string(AsciMapLoader.asci2)
	print("Loading grid map, size " + str(map.width) + " by " + str(map.height))
	var height:int = map.height
	for z in range(0, height):
		var line = map.lines[z]
		var width = line.length()
		for x in range(0, width):
			var pos:Vector3 = Vector3(x, y, z)
			pos += posOffset
			var c:String = line[x]
			var prefab:Spatial = null
			if c == '#':
				if _check_all_neighbours_equal(map.lines, x, z, width, height, '#'):
					continue
				prefab = _prefab_wall.instance()
			elif c == ' ':
				prefab = _prefab_ground.instance()
			if prefab == null:
				continue
			self.add_child(prefab)
			prefab.global_transform.origin = pos
