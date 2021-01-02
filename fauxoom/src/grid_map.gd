extends Spatial

var _prefab_ground = preload("res://prefabs/grid_map/ground_tile.tscn")
var _prefab_wall = preload("res://prefabs/grid_map/wall_tile.tscn")
var _prefab_water = preload("res://prefabs/grid_map/water_tile.tscn")
var _prefab_spawn = preload("res://prefabs/spawn_point.tscn")
var _prefab_default_mob = preload("res://prefabs/sprite_object.tscn")

var _prefab_player = preload("res://prefabs/player.tscn")

var _wall_mat:SpatialMaterial = preload("res://assets/world/materials/mat_default_wall.tres")

const entTypePlayer = "player"
const entTypeMob = "mob"
const entTypeEnd = "end"
const entTypeKey = "key"

onready var _world_mesh:MeshGenerator = $world_mesh

# scene objects created
var _tiles = []
var _spawn_points = []
# var _live_ents = []

# constructed mesh
var _sTool:SurfaceTool = SurfaceTool.new()
var _tmpMesh = Mesh.new()
var _vertices = PoolVector3Array()
var _uvs = PoolVector2Array()
var _mat = SpatialMaterial.new()
var _colour = Color(0.9, 0.1, 0.1)

func _create_mesh_2() -> void:
	print("Spawn world mesh")
	_vertices.push_back(Vector3(-50, 0, 0))
	_vertices.push_back(Vector3(50, 0, 0))
	_vertices.push_back(Vector3(50, 50, 0))
	
	_uvs.push_back(Vector2(0, 0))
	_uvs.push_back(Vector2(1, 0))
	_uvs.push_back(Vector2(1, 1))
	
	_mat.albedo_color = _colour
	_sTool.begin(Mesh.PRIMITIVE_TRIANGLES)
	_sTool.set_material(_mat)
	
	for v in _vertices.size():
		_sTool.add_color(_colour)
		_sTool.add_uv(_uvs[v])
		_sTool.add_vertex(_vertices[v])
	_sTool.commit(_tmpMesh)
	_world_mesh.mesh = _tmpMesh

func _create_mesh() -> void:
	print("Run world mesh gen")
	_world_mesh.start_mesh()
	#_world_mesh.add_triangle(Vector3(-50, 0, 0), Vector3(50, 0, 0), Vector3(50, 50, 50), Vector2(0, 0), Vector2(1, 0), Vector2(1, 1))
	_world_mesh.add_triangle(-50, 0, 0,  50, 0, 0,  50, 50, 0,  0, 1,  1, 1,  1, 0)
	
	_world_mesh.add_triangle(-50, 0, 0,  50, 50, 0,  -50, 50, 0,  0, 1,  1, 0,  0, 0)
	_world_mesh.end_mesh()
	_world_mesh.set_material(_wall_mat)

func _clear_current() -> void:
	# TODO: proper clean delete of current map
	_tiles = []
	_spawn_points = []
	pass

func _pos_is_safe(x:int, y:int, width:int, height:int) -> bool:
	if x < 0 || x >= width:
		return false
	if y < 0 || y >= height:
		return false
	return true

func _set_spawn_points_visible(flag:bool) -> void:
	for i in range(0, _spawn_points.size()):
		_spawn_points[i].visible = flag

func _spawn_start_entities() -> void:
	# _prefab_default_mob
	var count:int = 0
	for i in range(0, _spawn_points.size()):
		#var pos:Vector3 = _spawn_points[i].global_transform.origin
		var t:Transform = _spawn_points[i].global_transform
		var prefab:Spatial = null
		var entType = _spawn_points[i].entType
		if entType == entTypeMob:
			prefab = _prefab_default_mob.instance()
		elif entType == entTypePlayer:
			prefab = _prefab_player.instance()
		else:
			_spawn_points[i].visible = true
		if prefab != null:
			self.add_child(prefab)
			prefab.global_transform = t
			count += 1
	print("Spawned " + str(count) + " ents")

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
	#print("count " + str(count) + " vs " + str(x) + ", " + str(y) + " w/h " + str(width) + ", " + str(height))
	return (count == 4)

func _spawn_map(map:Dictionary) -> void:
	var tileRadius:float = 2
	var y:float = -1
	var posOffset:Vector3 = Vector3(tileRadius * 0.5, 0, tileRadius * 0.5)
	print("Loading grid map, size " + str(map.width) + " by " + str(map.height))
	var height:int = map.height
	for z in range(0, height):
		var line = map.lines[z]
		var width = line.length()
		for x in range(0, width):
			var pos:Vector3 = Vector3(x * tileRadius, y, z * tileRadius)
			pos += posOffset
			var c:String = line[x]
			var prefab:Spatial = null
			var spawnGround:bool = false
			var isEntity:bool = false
			if c == '#':
				if _check_all_neighbours_equal(map.lines, x, z, width, height, '#'):
					continue
				prefab = _prefab_wall.instance()
			elif c == '.':
				prefab = _prefab_water.instance()
			elif c == 'x':
				prefab = _prefab_spawn.instance()
				prefab.entType = entTypeMob
				prefab.rotation_degrees = Vector3(0, rand_range(0, 359), 0)
				spawnGround = true
				isEntity = true
			elif c == 's':
				prefab = _prefab_spawn.instance()
				prefab.entType = entTypePlayer
				#prefab = _prefab_player.instance()
				spawnGround = true
				isEntity = true
			elif c == 'e':
				prefab = _prefab_spawn.instance()
				prefab.entType = entTypeEnd
				spawnGround = true
				isEntity = true
			elif c == 'k':
				prefab = _prefab_spawn.instance()
				prefab.entType = entTypeKey
				spawnGround = true
				isEntity = true
			elif c == ' ':
				spawnGround = true
			
			if prefab != null:
				self.add_child(prefab)
				prefab.global_transform.origin = pos
				if isEntity:
					_spawn_points.push_back(prefab)
				else:
					_tiles.push_back(prefab)
			
			# most entities will want a ground tile beneath them
			if spawnGround:
				var ground = _prefab_ground.instance()
				self.add_child(ground)
				ground.global_transform.origin = pos
				_tiles.push_back(_prefab_ground)
			
	print("Done with " + str(_tiles.size()) + " tiles and " + str(_spawn_points.size()) + " ents")
	_set_spawn_points_visible(false)
	_spawn_start_entities()
	_create_mesh()

func _ready():
	var txt:String = AsciMapLoader.get_default()
	var map:Dictionary = AsciMapLoader.read_string(txt)
	self._spawn_map(map)

func _process(_delta:float) -> void:
	var degrees = _world_mesh.rotation_degrees
	degrees.y += 45 * _delta
	_world_mesh.rotation_degrees = degrees
