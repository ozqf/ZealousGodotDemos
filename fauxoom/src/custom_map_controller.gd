extends Spatial
class_name CustomMapLoader

var _prefab_ground = preload("res://prefabs/grid_map/ground_tile.tscn")
var _prefab_wall = preload("res://prefabs/grid_map/wall_tile.tscn")
var _prefab_water = preload("res://prefabs/grid_map/water_tile.tscn")
var _prefab_spawn = preload("res://prefabs/spawn_point.tscn")
var _prefab_default_mob = preload("res://prefabs/sprite_object.tscn")
var _prefab_player = preload("res://prefabs/player.tscn")

func _ready() -> void:
	var map = AsciMapLoader.build_test_map()
	$map_gen.build_world_map(map)

	# generate entities
	var numEnts:int = map.spawns.size()
	print("Spawning " + str(numEnts) + " entities")
	var posOffset:Vector3 = Vector3(map.mapScale * 0.5, 0, map.mapScale * 0.5)
	for i in range(0, numEnts):
		var spawn:MapSpawnDef = map.spawns[i]
		var t:Transform = Transform.IDENTITY
		t.origin = spawn.position * map.mapScale
		t.origin += posOffset
		t.origin.y = -1
		var prefab = null
		if spawn.type == MapDef.ENT_TYPE_START:
			prefab = _prefab_player.instance()
		elif spawn.type == MapDef.ENT_TYPE_MOB_GRUNT:
			prefab = _prefab_default_mob.instance()
		
		if prefab == null:
			continue
		self.add_child(prefab)
		prefab.global_transform = t
