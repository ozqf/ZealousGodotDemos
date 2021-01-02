extends Spatial

var _prefab_ground = preload("res://prefabs/grid_map/ground_tile.tscn")
var _prefab_wall = preload("res://prefabs/grid_map/wall_tile.tscn")
var _prefab_water = preload("res://prefabs/grid_map/water_tile.tscn")
var _prefab_spawn = preload("res://prefabs/spawn_point.tscn")
var _prefab_default_mob = preload("res://prefabs/sprite_object.tscn")

var _prefab_player = preload("res://prefabs/player.tscn")

var _wall_mat:SpatialMaterial = preload("res://assets/world/materials/mat_default_wall.tres")
var _floor_mat:SpatialMaterial = preload("res://assets/world/materials/mat_default_ground.tres")
var _water_mat:SpatialMaterial = preload("res://assets/world/materials/mat_default_water.tres")
var _ceiling_mat:SpatialMaterial = preload("res://assets/world/materials/mat_default_ceiling.tres")

const entTypePlayer = "player"
const entTypeMob = "mob"
const entTypeEnd = "end"
const entTypeKey = "key"

onready var _world_mesh:MeshGenerator = $world_mesh
onready var _world_floor_mesh:MeshGenerator = $world_floor
onready var _world_water_mesh:MeshGenerator = $world_water
onready var _world_ceiling_mesh:MeshGenerator = $world_ceiling

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

func _create_test_mesh() -> void:
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

# spawn a box at given position (purely for debugging!
func _spawn_marker(pos:Vector3, prefabInstance) -> void:
	self.add_child(prefabInstance)
	prefabInstance.global_transform.origin = pos
	prefabInstance.scale = Vector3(0.25, 0.25, 0.25)

func _add_wall_geometry(pos:Vector3, radius:float) -> void:
	var diameter:float = radius * 2
	var tMin:Vector3 = Vector3(pos.x - radius, pos.y - diameter, pos.z - radius)
	var tMax:Vector3 = Vector3(pos.x + radius, pos.y + diameter, pos.z + radius)
#	_spawn_marker(tMin, _prefab_ground.instance())
#	_spawn_marker(tMax, _prefab_water.instance())
	
	var v1:Vector3 = Vector3(tMin.x, tMin.y, tMax.z)
	var v2:Vector3 = Vector3(tMax.x, tMax.y, tMax.z)
	var v3:Vector3 = Vector3(tMax.x, tMin.y, tMax.z)
	var v4:Vector3 = Vector3(tMin.x, tMax.y, tMax.z)
	
	var v5:Vector3 = Vector3(tMax.x, tMin.y, tMin.z)
	var v6:Vector3 = Vector3(tMin.x, tMax.y, tMin.z)
	var v7:Vector3 = Vector3(tMin.x, tMin.y, tMin.z)
	var v8:Vector3 = Vector3(tMax.x, tMax.y, tMin.z)
	
	var uv1:Vector2 = Vector2(0, 2)
	var uv2:Vector2 = Vector2(1, 0)
	var uv3:Vector2 = Vector2(1, 2)
	var uv4:Vector2 = Vector2(0, 0)
	
	# + z
	_world_mesh.add_triangle_v(v1, v2, v3, uv1, uv2, uv3)
	_world_mesh.add_triangle_v(v1, v4, v2, uv1, uv4, uv2)
	# - z
	_world_mesh.add_triangle_v(v7, v4, v1, uv1, uv2, uv3)
	_world_mesh.add_triangle_v(v7, v6, v4, uv1, uv4, uv2)
	# + x
	_world_mesh.add_triangle_v(v3, v8, v5, uv1, uv2, uv3)
	_world_mesh.add_triangle_v(v3, v2, v8, uv1, uv4, uv2)
	# - x
	_world_mesh.add_triangle_v(v5, v6, v7, uv1, uv2, uv3)
	_world_mesh.add_triangle_v(v5, v8, v6, uv1, uv4, uv2)
	# + y
	_world_mesh.add_triangle_v(v4, v8, v2, uv1, uv2, uv3)
	_world_mesh.add_triangle_v(v4, v6, v8, uv1, uv4, uv2)

func _add_floor_geometry(pos:Vector3, radius:float) -> void:
	var diameter:float = radius * 2
	var tMin:Vector3 = Vector3(pos.x - radius, pos.y - diameter, pos.z - radius)
	var tMax:Vector3 = Vector3(pos.x + radius, pos.y, pos.z + radius)
#	_spawn_marker(tMin, _prefab_ground.instance())
#	_spawn_marker(tMax, _prefab_water.instance())
	
	var v1:Vector3 = Vector3(tMin.x, tMin.y, tMax.z)
	var v2:Vector3 = Vector3(tMax.x, tMax.y, tMax.z)
	var v3:Vector3 = Vector3(tMax.x, tMin.y, tMax.z)
	var v4:Vector3 = Vector3(tMin.x, tMax.y, tMax.z)
	
	var v5:Vector3 = Vector3(tMax.x, tMin.y, tMin.z)
	var v6:Vector3 = Vector3(tMin.x, tMax.y, tMin.z)
	var v7:Vector3 = Vector3(tMin.x, tMin.y, tMin.z)
	var v8:Vector3 = Vector3(tMax.x, tMax.y, tMin.z)
	
	var uv1:Vector2 = Vector2(0, 1)
	var uv2:Vector2 = Vector2(1, 0)
	var uv3:Vector2 = Vector2(1, 1)
	var uv4:Vector2 = Vector2(0, 0)
	
	# + y
	_world_floor_mesh.add_triangle_v(v4, v8, v2, uv1, uv2, uv3)
	_world_floor_mesh.add_triangle_v(v4, v6, v8, uv1, uv4, uv2)
	
	# + z
	_world_mesh.add_triangle_v(v1, v2, v3, uv1, uv2, uv3)
	_world_mesh.add_triangle_v(v1, v4, v2, uv1, uv4, uv2)
	# - z
	_world_mesh.add_triangle_v(v7, v4, v1, uv1, uv2, uv3)
	_world_mesh.add_triangle_v(v7, v6, v4, uv1, uv4, uv2)
	# + x
	_world_mesh.add_triangle_v(v3, v8, v5, uv1, uv2, uv3)
	_world_mesh.add_triangle_v(v3, v2, v8, uv1, uv4, uv2)
	# - x
	_world_mesh.add_triangle_v(v5, v6, v7, uv1, uv2, uv3)
	_world_mesh.add_triangle_v(v5, v8, v6, uv1, uv4, uv2)

func _add_water_quad(pos:Vector3, radius:float) -> void:
	pos.y -= radius * 2
	var tMin:Vector3 = Vector3(pos.x - radius, pos.y, pos.z - radius)
	var tMax:Vector3 = Vector3(pos.x + radius, pos.y, pos.z + radius)
#	_spawn_marker(tMin, _prefab_ground.instance())
#	_spawn_marker(tMax, _prefab_water.instance())
	
	var v1:Vector3 = Vector3(tMin.x, tMin.y, tMax.z)
	var v2:Vector3 = Vector3(tMax.x, tMax.y, tMax.z)
	var v3:Vector3 = Vector3(tMax.x, tMin.y, tMax.z)
	var v4:Vector3 = Vector3(tMin.x, tMax.y, tMax.z)
	
	var v5:Vector3 = Vector3(tMax.x, tMin.y, tMin.z)
	var v6:Vector3 = Vector3(tMin.x, tMax.y, tMin.z)
	var v7:Vector3 = Vector3(tMin.x, tMin.y, tMin.z)
	var v8:Vector3 = Vector3(tMax.x, tMax.y, tMin.z)
	
	var uv1:Vector2 = Vector2(0, 1)
	var uv2:Vector2 = Vector2(1, 0)
	var uv3:Vector2 = Vector2(1, 1)
	var uv4:Vector2 = Vector2(0, 0)
	
	# + y
	_world_water_mesh.add_triangle_v(v4, v8, v2, uv1, uv2, uv3)
	_world_water_mesh.add_triangle_v(v4, v6, v8, uv1, uv4, uv2)


func _add_ceiling_quad(pos:Vector3, radius:float) -> void:
	pos.y += radius * 2
	var tMin:Vector3 = Vector3(pos.x - radius, pos.y, pos.z - radius)
	var tMax:Vector3 = Vector3(pos.x + radius, pos.y, pos.z + radius)
#	_spawn_marker(tMin, _prefab_ground.instance())
#	_spawn_marker(tMax, _prefab_water.instance())
	
	var v1:Vector3 = Vector3(tMin.x, tMin.y, tMax.z)
	var v2:Vector3 = Vector3(tMax.x, tMax.y, tMax.z)
	var v3:Vector3 = Vector3(tMax.x, tMin.y, tMax.z)
	var v4:Vector3 = Vector3(tMin.x, tMax.y, tMax.z)
	
	var v5:Vector3 = Vector3(tMax.x, tMin.y, tMin.z)
	var v6:Vector3 = Vector3(tMin.x, tMax.y, tMin.z)
	var v7:Vector3 = Vector3(tMin.x, tMin.y, tMin.z)
	var v8:Vector3 = Vector3(tMax.x, tMax.y, tMin.z)
	
	var uv1:Vector2 = Vector2(0, 1)
	var uv2:Vector2 = Vector2(1, 0)
	var uv3:Vector2 = Vector2(1, 1)
	var uv4:Vector2 = Vector2(0, 0)
	
	# - y
	# 7 3 5
	# 7 1 3
	_world_ceiling_mesh.add_triangle_v(v7, v3, v5, uv1, uv2, uv3)
	_world_ceiling_mesh.add_triangle_v(v7, v1, v3, uv1, uv4, uv2)

#########################################################
# Spawn map
#########################################################
func _spawn_map(map:Dictionary) -> void:
	var tileDiameter:float = 2
	var y:float = -1
	var posOffset:Vector3 = Vector3(tileDiameter * 0.5, 0, tileDiameter * 0.5)
	print("Loading grid map, size " + str(map.width) + " by " + str(map.height))
	
	_world_mesh.start_mesh()
	_world_floor_mesh.start_mesh()
	_world_water_mesh.start_mesh()
	_world_ceiling_mesh.start_mesh()
	
	var height:int = map.height
	for z in range(0, height):
		var line = map.lines[z]
		var width = line.length()
		for x in range(0, width):
			var pos:Vector3 = Vector3(x * tileDiameter, y, z * tileDiameter)
			pos += posOffset
			var c:String = line[x]
			var prefab:Spatial = null
			var spawnGround:bool = false
			var isEntity:bool = false
			if c == '#':
				if _check_all_neighbours_equal(map.lines, x, z, width, height, '#'):
					continue
				#prefab = _prefab_wall.instance()
				_add_wall_geometry(pos, tileDiameter * 0.5)
			elif c == '.':
				# prefab = _prefab_water.instance()
				#pos.y -= tileDiameter
				_add_water_quad(pos, tileDiameter * 0.5)
				_add_ceiling_quad(pos, tileDiameter * 0.5)
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
				_add_floor_geometry(pos, tileDiameter * 0.5)
				_add_ceiling_quad(pos, tileDiameter * 0.5)
#				var ground = _prefab_ground.instance()
#				self.add_child(ground)
#				ground.global_transform.origin = pos
#				_tiles.push_back(_prefab_ground)
			
	print("Done with " + str(_tiles.size()) + " tiles and " + str(_spawn_points.size()) + " ents")
	_set_spawn_points_visible(false)
	_spawn_start_entities()
	#_create_test_mesh()
	_world_mesh.end_mesh()
	_world_mesh.set_material(_wall_mat)
	_world_floor_mesh.end_mesh()
	_world_floor_mesh.set_material(_floor_mat)
	_world_water_mesh.end_mesh()
	_world_water_mesh.set_material(_water_mat)
	_world_ceiling_mesh.end_mesh()
	_world_ceiling_mesh.set_material(_ceiling_mat)

func _ready():
	var txt:String = AsciMapLoader.get_default()
	var map:Dictionary = AsciMapLoader.read_string(txt)
	self._spawn_map(map)

func _process(_delta:float) -> void:
#	var degrees = _world_mesh.rotation_degrees
#	degrees.y += 45 * _delta
#	_world_mesh.rotation_degrees = degrees
	pass
