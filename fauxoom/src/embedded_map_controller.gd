extends Spatial

var _prefab_player = preload("res://prefabs/player.tscn")
var _prefab_mob_gunner = preload("res://prefabs/entities/mob_gunner.tscn")

func _ready():
	var spawnNodes = get_tree().get_nodes_in_group("embedded_spawns")
	var l:int = spawnNodes.size()
	print("Embedded map found " + str(l) + " embedded spawn points")
	for i in range(0, l):
		var spawn:MapSpawnDef = spawnNodes[i].get_def()
		var prefab = null
		if spawn.type == 1:
			prefab = _prefab_mob_gunner.instance()
		if spawn.type == 2:
			prefab = _prefab_player.instance()
		
		if prefab == null:
			continue

		var t:Transform = Transform.IDENTITY
		t = t.rotated(Vector3.UP, deg2rad(spawn.yaw))
		t.origin = spawn.position
		self.add_child(prefab)
		prefab.global_transform = t
