extends Spatial

var _prefab_player = preload("res://prefabs/player.tscn")
var _prefab_mob_gunner = preload("res://prefabs/dynamic_entities/mob_gunner.tscn")
var _prefab_horde_spawn = preload("res://prefabs/static_entities/horde_spawn.tscn")

onready var _camera:Camera = $Camera

var _startEnts = []

func _ready() -> void:
	add_to_group(Groups.GAME_GROUP_NAME)

func game_on_player_spawned(_player) -> void:
	_camera.current = false

func game_on_reset() -> void:
	_camera.current = true

func _ready_defunct_again() -> void:
	_startEnts = get_tree().get_nodes_in_group("entities")
	var l:int = _startEnts.size()
	print("Found " + str(l) + " static ents")
	start_play()

func start_play() -> void:
	var l:int = _startEnts.size()
	for _i in range (0, l):
		var ent = _startEnts[_i]
		if ent.has_method("start_play"):
			ent.start_play($dynamic as Spatial)

func _ready_defunct():
	var spawnNodes = get_tree().get_nodes_in_group("embedded_spawns")
	var l:int = spawnNodes.size()
	print("Embedded map found " + str(l) + " embedded spawn points")
	for i in range(0, l):
		var spawn:MapSpawnDef = spawnNodes[i].get_def()
		var prefab = null
		if spawn.type == MapDef.ENT_TYPE_MOB_GRUNT:
			prefab = _prefab_mob_gunner.instance()
		elif spawn.type == MapDef.ENT_TYPE_START:
			prefab = _prefab_player.instance()
		elif spawn.type == MapDef.ENT_TYPE_HORDE_SPAWN:
			prefab = _prefab_horde_spawn.instance()
			prefab.triggerName = spawn.triggerName
			prefab.triggerTargetName = spawn.triggerTargetName
		else:
			print("Unrecognised embedded ent type " + str(spawn.type))
			continue
		
		# if prefab == null:
		# 	continue

		var t:Transform = Transform.IDENTITY
		t = t.rotated(Vector3.UP, deg2rad(spawn.yaw))
		t.origin = spawn.position
		self.add_child(prefab)
		prefab.global_transform = t
