extends Spatial
class_name CustomMapLoader

var _prefab_ground = preload("res://prefabs/grid_map/ground_tile.tscn")
var _prefab_wall = preload("res://prefabs/grid_map/wall_tile.tscn")
var _prefab_water = preload("res://prefabs/grid_map/water_tile.tscn")
var _prefab_spawn = preload("res://map_gen/prefabs/actor_spawn.tscn")
var _prefab_default_mob = preload("res://prefabs/sprite_object.tscn")
var _prefab_player = preload("res://prefabs/player.tscn")

var _prefab_mob_gunner = preload("res://prefabs/dynamic_entities/mob_gunner.tscn")

var _map:MapDef = null

var _playerOrigin:Vector3 = Vector3()

enum GameState { Pregame, Playing, Won, Lost }

var _state = GameState.Pregame

var _orbitDegrees:float = 0
var _orbitRate:float = 35

func _ready() -> void:
	print("- Custom map ready -")
	add_to_group("game")
	add_to_group("console")
	
	_map = Main.get_map()
	# _map = MapEncoder.b64_to_map(MapEncoder.b64TestSmall)
	if _map == null:
		_map = AsciMapLoader.build_test_map()
	$map_gen.build_world_map(_map)

func console_on_exec(txt:String) -> void:
	if txt == "complete":
		get_tree().call_group("game", "game_on_level_completed")

func game_on_level_completed() -> void:
	if _state != GameState.Playing:
		print("Complete ignored - not playing!")
		return
	print("Level completed")
	_state = GameState.Won
	$overlay/complete.visible = true

func game_on_player_died(_info:Dictionary) -> void:
	if _state != GameState.Playing:
		print("Player death ignored - not playing!")
		return
	print("Player died")
	_state = GameState.Lost
	$overlay/death.visible = true

func _orbit_camera(_delta:float) -> void:
	_orbitDegrees += _orbitRate * _delta
	var cam:Camera = $map_gen/Camera
	if cam == null:
		return
	var radians:float = deg2rad(_orbitDegrees)
	var _radius:float = _map.width + _map.height
	var pos:Vector3 = Vector3()
	var centre:Vector3 = _map.centre()
	pos.x = cos(radians) * _radius
	pos.y = 20
	pos.z = sin(radians) * _radius
	cam.global_transform.origin = centre + pos
	cam.look_at(centre, Vector3.UP)

func spawn_entities() -> void:
	# generate entities
	var numEnts:int = _map.spawns.size()
	print("Spawning " + str(numEnts) + " entities")
	var posOffset:Vector3 = Vector3(_map.scale * 0.5, 0, _map.scale * 0.5)
	for i in range(0, numEnts):
		var spawn:MapSpawnDef = _map.spawns[i]
		var t:Transform = Transform.IDENTITY
		# rotate then translate
		t = t.rotated(Vector3.UP, deg2rad(spawn.yaw))
		t.origin = spawn.position * _map.scale
		t.origin += posOffset
		t.origin.y = -1
		var prefab = null
		if spawn.type == MapDef.ENT_TYPE_START:
			prefab = _prefab_player.instance()
		elif spawn.type == MapDef.ENT_TYPE_MOB_GRUNT:
			prefab = _prefab_mob_gunner.instance()
			# prefab = _prefab_default_mob.instance()
		else:
			prefab = _prefab_spawn.instance()
		
		if prefab == null:
			continue
		self.add_child(prefab)
		prefab.global_transform = t

#func game_on_load_base64(b64:String) -> void:
#	print("grid_map load from " + str(b64.length()) + " base64 chars")
#	var bytes:PoolByteArray = Marshalls.base64_to_raw(b64)
#	print("Read " + str(bytes.size()) + " bytes")
#	MapEncoder.b64_to_map(b64)
		
#func game_on_save_map_text() -> void:
#	# var b64 = AsciMapLoader.str_to_b64(_mapText)
#	var b64:String = MapEncoder.map_to_b64(_map)
#	get_tree().call_group("game", "game_on_wrote_map_text", b64)

func _process(delta) -> void:
	if _state == GameState.Pregame:
		_orbit_camera(delta)
		if Input.is_action_just_pressed("ui_select"):
			_state = GameState.Playing
			$overlay/pregame.visible = false
			spawn_entities()
