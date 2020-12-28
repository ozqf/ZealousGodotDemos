extends Spatial

var _prefab_ground = preload("res://prefabs/grid_map/ground_tile.tscn")
var _prefab_wall = preload("res://prefabs/grid_map/wall_tile.tscn")

func _ready():
	var y:float = -10
	var map:Dictionary = AsciMapLoader.read_string(AsciMapLoader.asci2)
	print("Loading grid map, size " + str(map.width) + " by " + str(map.height))
	for z in range(0, map.height):
		var line = map.lines[z]
		var width = line.length()
		for x in range(0, width):
			var pos:Vector3 = Vector3(x, y, z)
			var c:String = line[x]
			var prefab:Spatial = null
			if c == '#':
				prefab = _prefab_wall.instance()
			elif c == ' ':
				prefab = _prefab_ground.instance()
			if prefab == null:
				continue
			self.add_child(prefab)
			prefab.global_transform.origin = pos
