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

const fWall:int = (1 << 0)
const fFloor:int = (1 << 1)
const fCeiling:int = (1 << 2)
const fWater:int = (1 << 3)

# display meshes
onready var _world_mesh:MeshGenerator = $world_mesh
onready var _world_floor_mesh:MeshGenerator = $world_floor
onready var _world_ceiling_mesh:MeshGenerator = $world_ceiling
onready var _world_water_mesh:MeshGenerator = $world_water

# collision meshes
onready var _world_hull:MeshGenerator = $world_hull
onready var _world_water_blocker:MeshGenerator = $world_hull_water

onready var _world_polygon:CollisionShape = $world_body/CollisionShape
onready var _player_blocker:CollisionShape = $player_water_blocker/CollisionShape

# scene objects created
var _tiles = []
var _spawn_points = []
# var _live_ents = []

var _tick:int = 0
var _building:bool = false
var _map:Dictionary
var _state:Dictionary = {
	perFrame = 40,
	tileCount = 0,
	tileTotal = 0
}

# constructed mesh
#var _sTool:SurfaceTool = SurfaceTool.new()
#var _tmpMesh = Mesh.new()
#var _vertices = PoolVector3Array()
#var _uvs = PoolVector2Array()
#var _mat = SpatialMaterial.new()
#var _colour = Color(0.9, 0.1, 0.1)

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
	var spawnedPlayer:bool = false
	for i in range(0, _spawn_points.size()):
		#var pos:Vector3 = _spawn_points[i].global_transform.origin
		var t:Transform = _spawn_points[i].global_transform
		var prefab:Spatial = null
		var entType = _spawn_points[i].entType
		if entType == entTypeMob:
			prefab = _prefab_default_mob.instance()
		elif entType == entTypePlayer:
			prefab = _prefab_player.instance()
			spawnedPlayer = true
		else:
			_spawn_points[i].visible = true
		if prefab != null:
			self.add_child(prefab)
			prefab.global_transform = t
			count += 1
	print("Spawned " + str(count) + " ents")
	if !spawnedPlayer:
		add_child(_prefab_player.instance())

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

func _add_quad(v1:Vector3, v2:Vector3, v3:Vector3, v4:Vector3, uv1:Vector2, uv2:Vector2, uv3:Vector2, uv4:Vector2, flags:int) -> void:
	var addCollision:bool = false
	if flags & fWall:
		_world_mesh.add_triangle_v(v1, v2, v3, uv1, uv2, uv3)
		_world_mesh.add_triangle_v(v1, v4, v2, uv1, uv4, uv2)
		addCollision = true
	if flags & fFloor:
		_world_floor_mesh.add_triangle_v(v1, v2, v3, uv1, uv2, uv3)
		_world_floor_mesh.add_triangle_v(v1, v4, v2, uv1, uv4, uv2)
		addCollision = true
	if flags & fCeiling:
		_world_ceiling_mesh.add_triangle_v(v1, v2, v3, uv1, uv2, uv3)
		_world_ceiling_mesh.add_triangle_v(v1, v4, v2, uv1, uv4, uv2)
		addCollision = true
	if flags & fWater:
		_world_water_mesh.add_triangle_v(v1, v2, v3, uv1, uv2, uv3)
		_world_water_mesh.add_triangle_v(v1, v4, v2, uv1, uv4, uv2)
		addCollision = true
	
	_world_hull.add_triangle_v(v1, v2, v3, uv1, uv2, uv3)
	_world_hull.add_triangle_v(v1, v4, v2, uv1, uv4, uv2)

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
	_add_quad(v1, v2, v3, v4, uv1, uv2, uv3, uv4, fWall)
	# - z
	_add_quad(v7, v4, v1, v6, uv1, uv2, uv3, uv4, fWall)
	# + x
	_add_quad(v3, v8, v5, v2, uv1, uv2, uv3, uv4, fWall)
	# - x
	_add_quad(v5, v6, v7, v8, uv1, uv2, uv3, uv4, fWall)
	# + y
	#_add_quad(v4, v8, v2, v6, uv1, uv2, uv3, uv4, fWall)

func _add_floor_geometry(pos:Vector3, radius:float) -> void:
	_world_floor_mesh.set_next_colour(Color(1, 1, 0))
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
	#_world_floor_mesh.add_triangle_v(v4, v8, v2, uv1, uv2, uv3)
	#_world_floor_mesh.add_triangle_v(v4, v6, v8, uv1, uv4, uv2)
	_add_quad(v4, v8, v2, v6, uv1, uv2, uv3, uv4, fFloor)
	
	# + z
	_add_quad(v1, v2, v3, v4, uv1, uv2, uv3, uv4, fWall)
	# - z
	_add_quad(v7, v4, v1, v6, uv1, uv2, uv3, uv4, fWall)
	# + x
	_add_quad(v3, v8, v5, v2, uv1, uv2, uv3, uv4, fWall)
	# - x
	_add_quad(v5, v6, v7, v8, uv1, uv2, uv3, uv4, fWall)
	
	# + z
#	_world_hull.add_triangle_v(v1, v2, v3, uv1, uv2, uv3)
#	_world_hull.add_triangle_v(v1, v4, v2, uv1, uv4, uv2)
#	# - z
#	_world_hull.add_triangle_v(v7, v4, v1, uv1, uv2, uv3)
#	_world_hull.add_triangle_v(v7, v6, v4, uv1, uv4, uv2)
#	# + x
#	_world_hull.add_triangle_v(v3, v8, v5, uv1, uv2, uv3)
#	_world_hull.add_triangle_v(v3, v2, v8, uv1, uv4, uv2)
#	# - x
#	_world_hull.add_triangle_v(v5, v6, v7, uv1, uv2, uv3)
#	_world_hull.add_triangle_v(v5, v8, v6, uv1, uv4, uv2)

func _add_water_quad(pos:Vector3, radius:float) -> void:
	var origin:Vector3 = pos
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
	#_world_water_mesh.add_triangle_v(v4, v8, v2, uv1, uv2, uv3)
	#_world_water_mesh.add_triangle_v(v4, v6, v8, uv1, uv4, uv2)
	_add_quad(v4, v8, v2, v6, uv1, uv2, uv3, uv4, fWater)
	
	# player blocker quads
	var blockRadius:float = radius - 0.35
	pos = origin
	tMin = Vector3(pos.x - blockRadius, pos.y - blockRadius, pos.z - blockRadius)
	tMax = Vector3(pos.x + blockRadius, pos.y + blockRadius, pos.z + blockRadius)
#	_spawn_marker(tMin, _prefab_ground.instance())
#	_spawn_marker(tMax, _prefab_water.instance())
	
	v1 = Vector3(tMin.x, tMin.y, tMax.z)
	v2 = Vector3(tMax.x, tMax.y, tMax.z)
	v3 = Vector3(tMax.x, tMin.y, tMax.z)
	v4 = Vector3(tMin.x, tMax.y, tMax.z)
	
	v5 = Vector3(tMax.x, tMin.y, tMin.z)
	v6 = Vector3(tMin.x, tMax.y, tMin.z)
	v7 = Vector3(tMin.x, tMin.y, tMin.z)
	v8 = Vector3(tMax.x, tMax.y, tMin.z)
	
	# + z
	_world_water_blocker.add_triangle_v(v1, v2, v3, uv1, uv2, uv3)
	_world_water_blocker.add_triangle_v(v1, v4, v2, uv1, uv4, uv2)
	#_add_quad(v1, v2, v3, v4, uv1, uv2, uv3, uv4, fWall)
	# - z
#	_add_quad(v7, v4, v1, v6, uv1, uv2, uv3, uv4, fWall)
	_world_water_blocker.add_triangle_v(v7, v4, v1, uv1, uv2, uv3)
	_world_water_blocker.add_triangle_v(v7, v6, v4, uv1, uv4, uv2)
	# + x
	_world_water_blocker.add_triangle_v(v3, v8, v5, uv1, uv2, uv3)
	_world_water_blocker.add_triangle_v(v3, v2, v8, uv1, uv4, uv2)
	# - x
	_world_water_blocker.add_triangle_v(v5, v6, v7, uv1, uv2, uv3)
	_world_water_blocker.add_triangle_v(v5, v8, v6, uv1, uv4, uv2)

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
	#_world_ceiling_mesh.add_triangle_v(v7, v3, v5, uv1, uv2, uv3)
	#_world_ceiling_mesh.add_triangle_v(v7, v1, v3, uv1, uv4, uv2)
	_add_quad(v7, v3, v5, v1, uv1, uv2, uv3, uv4, fCeiling)

#########################################################
# Spawn cell
#########################################################
func _spawn_cell(x:int, y:int, z:int, tileDiameter:int, posOffset:Vector3, map:Dictionary) -> void:
	var line = map.lines[z]
	var c = line[x]
	var radius:float = tileDiameter * 0.5
	#print("Spawn " + str(c) + " cell at " + str(Vector3(x, y, z)))
	var width = map.width
	var height = map.height
	var pos:Vector3 = Vector3(x * tileDiameter, y, z * tileDiameter)
	pos += posOffset
	#var c:String = line[x]
	var prefab:Spatial = null
	var spawnGround:bool = false
	var isEntity:bool = false
	if c == '#':
		if _check_all_neighbours_equal(map.lines, x, z, width, height, '#'):
			#prefab = _prefab_wall.instance()
			return
		_add_wall_geometry(pos, radius)
	elif c == '.':
		# prefab = _prefab_water.instance()
		#pos.y -= tileDiameter
		_add_water_quad(pos, radius)
		_add_ceiling_quad(pos, radius)
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
		_add_floor_geometry(pos, radius)
		_add_ceiling_quad(pos, radius)

#########################################################
# Spawn map
#########################################################
func _pos_from_index(i:int, w:int) -> Vector2:
	return Vector2(i % w, floor(i / w))

func _spawn_map(map:Dictionary) -> void:
	_start_build(map)
	
	var tileDiameter:float = 2
	var y:float = -1
	var posOffset:Vector3 = Vector3(tileDiameter * 0.5, 0, tileDiameter * 0.5)
	
	var height:int = map.height
	for z in range(0, height):
		var line = map.lines[z]
		var width = line.length()
		for x in range(0, width):
			_spawn_cell(x, y, z, tileDiameter, posOffset, map)
	_end_build()

func _start_build(map:Dictionary) -> void:
	if _building:
		return
	
	$ui_layer/loading_screen.visible = true
	_map = map
	_building = true
	_world_hull.start_mesh()
	_world_water_blocker.start_mesh()
	
	_world_mesh.start_mesh()
	_world_floor_mesh.start_mesh()
	_world_water_mesh.start_mesh()
	_world_ceiling_mesh.start_mesh()
	
	_state.tileCount = 0
	_state.tileTotal = _map.width * _map.height
	
	print("Loading grid map, size " + str(map.width) + " by " + str(map.height))
	print("\tTotal tiles: " + str(_state.tileTotal))

func _iterate_build() -> void:
	if !_building:
		return
	var count = 0
	var tileDiameter:float = 2
	var y:float = -1
	var posOffset:Vector3 = Vector3(tileDiameter * 0.5, 0, tileDiameter * 0.5)
	while _state.tileCount < _state.tileTotal:
		if count >= _state.perFrame:
			#print("Frame break")
			return
		var cellPos:Vector2 = _pos_from_index(_state.tileCount, _map.width)
		#print("cell pos for " + str(_state.tileCount) + " at: " + str(cellPos))
		_spawn_cell(cellPos.x, y, cellPos.y, tileDiameter, posOffset, _map)
		_state.tileCount += 1
		count += 1
	_end_build()

func _end_build() -> void:
	print("Done with " + str(_tiles.size()) + " tiles and " + str(_spawn_points.size()) + " ents")
	_set_spawn_points_visible(false)
	_spawn_start_entities()
	# end collision meshes
	_world_hull.end_mesh()
	_world_hull.set_material(_floor_mat)
	_world_hull.visible = false
	_world_water_blocker.end_mesh()
	_world_water_blocker.set_material(_floor_mat)
	_world_water_blocker.visible = false
	
	# apply collision meshes
	_world_polygon.shape = _world_hull.get_collision_mesh()
	_player_blocker.shape = _world_water_blocker.get_collision_mesh()
	
	# finish display meshes
	_world_mesh.end_mesh()
	_world_mesh.set_material(_wall_mat)
	_world_floor_mesh.end_mesh()
	_world_floor_mesh.set_material(_floor_mat)
	_world_water_mesh.end_mesh()
	_world_water_mesh.set_material(_water_mat)
	_world_ceiling_mesh.end_mesh()
	_world_ceiling_mesh.set_material(_ceiling_mat)
	
	$ui_layer/loading_screen.visible = false
	_building = false

func _process(_delta:float) -> void:
	#var degrees = _world_mesh.rotation_degrees
	#degrees.y += 45 * _delta
	#_world_mesh.rotation_degrees = degrees
	
	# begin build process after godot scene has loaded
	if _tick == 10:
		var txt:String = AsciMapLoader.get_default()
		var map:Dictionary = AsciMapLoader.read_string(txt)
		#self._spawn_map(map)
		self._start_build(map)
	if _building:
		_iterate_build()
		var percentage:float = floor((float(_state.tileCount) / float(_state.tileTotal)) * 100)
		print(str(percentage))
		$ui_layer/loading_screen/loading_label.text = "Loading " + str(percentage) + "%"
	_tick += 1
