extends Spatial
class_name CustomMapLoader

var _prefab_ground = preload("res://prefabs/grid_map/ground_tile.tscn")
var _prefab_wall = preload("res://prefabs/grid_map/wall_tile.tscn")
var _prefab_water = preload("res://prefabs/grid_map/water_tile.tscn")
var _prefab_spawn = preload("res://map_gen/prefabs/spawn_point.tscn")
var _prefab_default_mob = preload("res://prefabs/sprite_object.tscn")
var _prefab_player = preload("res://prefabs/player.tscn")

var _map:MapDef = null

func _ready() -> void:
	add_to_group("game")

	_map = AsciMapLoader.build_test_map()
	# _map = MapEncoder.b64_to_map(MapEncoder.b64TestSmall)
	if _map == null:
		return
	$map_gen.build_world_map(_map)

	# generate entities
	var numEnts:int = _map.spawns.size()
	print("Spawning " + str(numEnts) + " entities")
	var posOffset:Vector3 = Vector3(_map.mapScale * 0.5, 0, _map.mapScale * 0.5)
	for i in range(0, numEnts):
		var spawn:MapSpawnDef = _map.spawns[i]
		var t:Transform = Transform.IDENTITY
		# rotate then translate
		t = t.rotated(Vector3.UP, deg2rad(spawn.yaw))
		t.origin = spawn.position * _map.mapScale
		t.origin += posOffset
		t.origin.y = -1
		var prefab = null
		if spawn.type == MapDef.ENT_TYPE_START:
			prefab = _prefab_player.instance()
		elif spawn.type == MapDef.ENT_TYPE_MOB_GRUNT:
			prefab = _prefab_default_mob.instance()
		else:
			prefab = _prefab_spawn.instance()
		
		if prefab == null:
			continue
		self.add_child(prefab)
		prefab.global_transform = t

func on_load_base64(b64:String) -> void:
	print("grid_map load from " + str(b64.length()) + " base64 chars")
	var bytes:PoolByteArray = Marshalls.base64_to_raw(b64)
	print("Read " + str(bytes.size()) + " bytes")
	MapEncoder.b64_to_map(b64)
		
func on_save_map_text() -> void:
	# var b64 = AsciMapLoader.str_to_b64(_mapText)
	var b64:String = MapEncoder.map_to_b64(_map)
	get_tree().call_group("game", "on_wrote_map_text", b64)

