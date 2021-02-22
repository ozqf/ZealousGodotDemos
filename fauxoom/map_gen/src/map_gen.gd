extends Spatial
class_name MapGen

var _prefab_ground = preload("res://prefabs/grid_map/ground_tile.tscn")
var _prefab_wall = preload("res://prefabs/grid_map/wall_tile.tscn")
var _prefab_water = preload("res://prefabs/grid_map/water_tile.tscn")
var _prefab_spawn = preload("res://map_gen/prefabs/actor_spawn.tscn")
var _prefab_default_mob = preload("res://prefabs/sprite_object.tscn")

var _prefab_player = preload("res://prefabs/player.tscn")

var _wall_mat:SpatialMaterial = preload("res://assets/world/materials/mat_default_wall.tres")
var _floor_mat:SpatialMaterial = preload("res://assets/world/materials/mat_default_ground.tres")
var _water_mat:SpatialMaterial = preload("res://assets/world/materials/mat_default_water.tres")
var _ceiling_mat:SpatialMaterial = preload("res://assets/world/materials/mat_default_ceiling.tres")

const fWall:int = (1 << 0)
const fFloor:int = (1 << 1)
const fCeiling:int = (1 << 2)
const fWater:int = (1 << 3)

var _noCeiling:bool = true

const _tile_types:Dictionary = {
	str(MapDef.TILE_PATH): 0
}

onready var _camera:Camera = $Camera

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

###########################################
# Add geometry
###########################################

func _set_world_boundary(width:int, height:int, tileSize:int) -> void:
	var t:Transform = Transform()
	var node:Spatial = $world_boundary/north
	var w:int = width * tileSize
	var h:int = height * tileSize
	# print("Boundary size: " + str(w) + " by " + str(h))
	
	t.origin = Vector3(w / 2.0, 0, -1)
	node.scale = Vector3(w + 2, 1, 1)
	node.global_transform = t
	
	node = $world_boundary/south
	t.origin = Vector3(w / 2.0, 0, h + 1)
	node.scale = Vector3(w + 2, 1, 1)
	node.global_transform = t
	
	node = $world_boundary/west
	t.origin = Vector3(-1, 0, h / 2.0)
	node.scale = Vector3(1, 1, h + 2)
	node.global_transform = t
	
	node = $world_boundary/east
	t.origin = Vector3(w + 1, 0, h / 2.0)
	node.scale = Vector3(1, 1, h + 2)
	node.global_transform = t

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
	
	if addCollision:
		_world_hull.add_triangle_v(v1, v2, v3, uv1, uv2, uv3)
		_world_hull.add_triangle_v(v1, v4, v2, uv1, uv4, uv2)

func _add_wall_geometry(pos:Vector3, radius:float, neighbours:int) -> void:
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
	if (neighbours & MapDef.NEIGHBOUR_FLAG_SOUTH) == 0:
		_add_quad(v1, v2, v3, v4, uv1, uv2, uv3, uv4, fWall)

	# - z
	if (neighbours & MapDef.NEIGHBOUR_FLAG_NORTH) == 0:
		_add_quad(v5, v6, v7, v8, uv1, uv2, uv3, uv4, fWall)
	
	# - x
	if (neighbours & MapDef.NEIGHBOUR_FLAG_WEST) == 0:
		_add_quad(v7, v4, v1, v6, uv1, uv2, uv3, uv4, fWall)

	# + x
	if (neighbours & MapDef.NEIGHBOUR_FLAG_EAST) == 0:
		_add_quad(v3, v8, v5, v2, uv1, uv2, uv3, uv4, fWall)

	# + y
	#_add_quad(v4, v8, v2, v6, uv1, uv2, uv3, uv4, fWall)

func _add_floor_geometry(pos:Vector3, radius:float) -> void:
	_world_floor_mesh.set_next_colour(Color(1, 1, 0))
	var diameter:float = radius * 2
	var tMin:Vector3 = Vector3(pos.x - radius, pos.y - diameter, pos.z - radius)
	var tMax:Vector3 = Vector3(pos.x + radius, pos.y, pos.z + radius)

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
	# _world_hull.add_triangle_v(v1, v2, v3, uv1, uv2, uv3)
	# _world_hull.add_triangle_v(v1, v4, v2, uv1, uv4, uv2)
	# # - z
	# _world_hull.add_triangle_v(v7, v4, v1, uv1, uv2, uv3)
	# _world_hull.add_triangle_v(v7, v6, v4, uv1, uv4, uv2)
	# # + x
	# _world_hull.add_triangle_v(v3, v8, v5, uv1, uv2, uv3)
	# _world_hull.add_triangle_v(v3, v2, v8, uv1, uv4, uv2)
	# # - x
	# _world_hull.add_triangle_v(v5, v6, v7, uv1, uv2, uv3)
	# _world_hull.add_triangle_v(v5, v8, v6, uv1, uv4, uv2)

func _add_water_quad(pos:Vector3, radius:float) -> void:
	var origin:Vector3 = pos
	pos.y -= radius * 2
	var tMin:Vector3 = Vector3(pos.x - radius, pos.y, pos.z - radius)
	var tMax:Vector3 = Vector3(pos.x + radius, pos.y, pos.z + radius)

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
	# _add_quad(v7, v4, v1, v6, uv1, uv2, uv3, uv4, fWall)
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
	#var v2:Vector3 = Vector3(tMax.x, tMax.y, tMax.z)
	var v3:Vector3 = Vector3(tMax.x, tMin.y, tMax.z)
	#var v4:Vector3 = Vector3(tMin.x, tMax.y, tMax.z)
	
	var v5:Vector3 = Vector3(tMax.x, tMin.y, tMin.z)
	#var v6:Vector3 = Vector3(tMin.x, tMax.y, tMin.z)
	var v7:Vector3 = Vector3(tMin.x, tMin.y, tMin.z)
	#var v8:Vector3 = Vector3(tMax.x, tMax.y, tMin.z)
	
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

# quad placed over wall blocks - only viewable in editor
func _add_solid_top_geometry(pos:Vector3, radius:float) -> void:
	pos.y += radius * 2
	var tMin:Vector3 = Vector3(pos.x - radius, pos.y, pos.z - radius)
	var tMax:Vector3 = Vector3(pos.x + radius, pos.y, pos.z + radius)
	# tMin *= -1
	# tMax *= -1

	var v2:Vector3 = Vector3(tMax.x, tMax.y, tMax.z)
	var v4:Vector3 = Vector3(tMin.x, tMax.y, tMax.z)
	
	var v6:Vector3 = Vector3(tMin.x, tMax.y, tMin.z)
	var v8:Vector3 = Vector3(tMax.x, tMax.y, tMin.z)
	
	var uv1:Vector2 = Vector2(0, 1)
	var uv2:Vector2 = Vector2(1, 0)
	var uv3:Vector2 = Vector2(1, 1)
	var uv4:Vector2 = Vector2(0, 0)
	
	# v7, v3, v5
	# v7, v1, v3
	
	_add_quad(v4, v8, v2, v6, uv1, uv2, uv3, uv4, fCeiling)
	# _add_quad(v7, v3, v5, v1, uv1, uv2, uv3, uv4, fCeiling)
	# _add_quad(v7, v3, v5, v1, uv1, uv2, uv3, uv4, fCeiling)

func _add_cell(map:MapDef, cellType:int, x:int, z:int, scale:int) -> void:
	# print("Add cell type " + str(cellType))
	var y:float = -1
	var radius:float = scale / 2.0
	var posOffset:Vector3 = Vector3(scale * 0.5, 0, scale * 0.5)
	var pos:Vector3 = Vector3(x * scale, y, z * scale)
	pos += posOffset
	var neighbours:int = map.get_neighbour_flags(x, z, cellType)
	if cellType == MapDef.TILE_WALL:
		_add_wall_geometry(pos, radius, neighbours)
		_add_solid_top_geometry(pos, radius)
	elif cellType == MapDef.TILE_VOID:
		_add_water_quad(pos, radius)
		if !_noCeiling:
			_add_ceiling_quad(pos, radius)
	else:
		_add_floor_geometry(pos, radius)
		if !_noCeiling:
			_add_ceiling_quad(pos, radius)

###########################################
# build steps
###########################################

func _clear() -> void:
	_world_mesh.clear()
	_world_floor_mesh.clear()
	_world_ceiling_mesh.clear()
	_world_water_mesh.clear()

	_world_hull.clear()
	_world_water_blocker.clear()

func _start_build(_map:MapDef) -> void:
	$ui_layer/loading_screen.visible = true
	
	_world_hull.start_mesh()
	_world_water_blocker.start_mesh()

	_world_mesh.start_mesh()
	_world_floor_mesh.start_mesh()
	_world_water_mesh.start_mesh()
	_world_ceiling_mesh.start_mesh()

func _finish_build(_map:MapDef) -> void:
	_set_world_boundary(_map.width, _map.height, _map.scale)
	# finish display meshes
	_world_mesh.end_mesh()
	_world_mesh.set_material(_wall_mat)
	_world_floor_mesh.end_mesh()
	_world_floor_mesh.set_material(_floor_mat)
	_world_water_mesh.end_mesh()
	_world_water_mesh.set_material(_water_mat)
	_world_ceiling_mesh.end_mesh()
	_world_ceiling_mesh.set_material(_ceiling_mat)
	
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

	var centre:Vector3 = Vector3()
	centre.x = (_map.width / 2.0) * _map.scale
	centre.z = (_map.height / 2.0) * _map.scale
	var t = _camera.global_transform
	t.origin = centre
	t.origin.y = 10
	t.origin.z -= 5
	_camera.global_transform = t
	_camera.look_at(centre, Vector3.UP)

	$ui_layer/loading_screen.visible = false
	# _camera.look_at(Vector3(), Vector3.UP)

# returns true if create was successful
func build_world_map(map:MapDef) -> bool:
	if map == null:
		return false
	
	# print("Map gen load map size " + str(map.width) + ", " + str(map.height))
	_clear()
	_start_build(map)
	for y in range (0, map.height):
		for x in range (0, map.width):
			var cellType:int = map.get_type_at(x, y)
			_add_cell(map, cellType, x, y, map.scale)
	_finish_build(map)
	return true
