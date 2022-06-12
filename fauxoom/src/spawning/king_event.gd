extends Spatial

const Enums = preload("res://src/enums.gd")

onready var _ent:Entity = $Entity

var _spawnPointTagsShared:EntTagSet
var _gateTags:EntTagSet
var _running:bool = false
var _spawnPointEnts = []
var _activeMobIds = []
var _mobSpawnTick:float = 0.1

var _killCount:int = 0
var _killTarget:int = 10

var _eventCount:int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group(Groups.ENTS_GROUP_NAME)
	var _result = _ent.connect("entity_append_state", self, "append_state")
	_result = _ent.connect("entity_restore_state", self, "restore_state")
	_spawnPointTagsShared = Game.new_tag_set()
	_gateTags = Game.new_tag_set()
	
	if Main.is_in_game():
		visible = false

func _reset() -> void:
	_killCount = 0
	_running = false
	pass

func ents_post_load() -> void:
	if Main.is_in_editor():
		return
	_spawnPointEnts = []
	if _spawnPointTagsShared.tag_count() >= 0:
		var tags = _spawnPointTagsShared.get_tags()
		for tag in tags:
			_spawnPointEnts.append_array(Ents.find_dynamic_entities(tag, "info_point"))
	print("King event found " + str(_spawnPointEnts.size()) + " spawn points")

func _message_gates(message:String) -> void:
	print("King event - message gates: " + message)
	var tags = _gateTags.get_tags()
	var tree = get_tree()
	var grp:String = Groups.ENTS_GROUP_NAME
	var fn:String = Groups.ENTS_FN_TRIGGER_ENTITIES
	for tag in tags:
		tree.call_group(grp, fn, tag, message, ZqfUtils.EMPTY_DICT)

func king_event_start(eventCount:int) -> void:
	print("King event - start")
	_running = true
	_eventCount = eventCount
	_killTarget = 6 + (_eventCount * 2)
	_message_gates("on")
	pass

func king_event_stop() -> void:
	print("King event - end")
	_message_gates("off")
	_reset()
	var grp:String = Groups.GAME_GROUP_NAME
	var fn:String = Groups.GAME_FN_EVENT_COMPLETE
	get_tree().call_group(grp, fn)
	pass

func append_state(_dict:Dictionary) -> void:
	_dict.xform = ZqfUtils.transform_to_dict(global_transform)
	_dict.spts = _spawnPointTagsShared.get_csv()
	_dict.gateTags = _gateTags.get_csv()

func restore_state(data:Dictionary) -> void:
	ZqfUtils.safe_dict_apply_transform(data, "xform", self)
	_spawnPointTagsShared.read_csv(ZqfUtils.safe_dict_s(data, "spts", _spawnPointTagsShared.get_csv()))
	_gateTags.read_csv(ZqfUtils.safe_dict_s(data, "gateTags", _gateTags.get_csv()))

func restore_from_editor(dict:Dictionary) -> void:
	_ent.restore_state(dict)

func get_editor_info() -> Dictionary:
	var info = _ent.get_editor_info_base()
	ZEEMain.create_field(info.fields, "spts", "Spawn Point tags", "tags", _spawnPointTagsShared.get_csv())
	ZEEMain.create_field(info.fields, "gateTags", "Gate tags", "tags", _gateTags.get_csv())
	return info

func _process(_delta:float) -> void:
	if _running:
		_tick_spawning(_delta)

#######################################
# (very) basic mob spawning
#######################################

func ents_mob_died_id(id:int) -> void:
	# print("King event saw mob die " + str(id))
	var i:int = _activeMobIds.find(id)
	if i == -1:
		return
	_activeMobIds.remove(i)
	_killCount += 1
	if _activeMobIds.size() == 0 && _killCount >= _killTarget:
		print("King event - All mobs dead!")
		king_event_stop()

func pick_spawn_point() -> Transform:
	var numPoints:int = _spawnPointEnts.size()
	if numPoints == 0:
		return self.global_transform
	var i:int = int(rand_range(0, numPoints))
	var ent:Entity = _spawnPointEnts[i]
	return ent.get_ent_transform()

func _max_mob_count() -> int:
	return 3 + _eventCount

func _pick_enemy_hard() -> int:
	var r:float = randf()
	if r > 0.95:
		return Enums.EnemyType.Golem
	elif r > 0.85:
		return Enums.EnemyType.Spider
	elif r > 0.7:
		return Enums.EnemyType.Cyclops
	elif r > 0.5:
		return Enums.EnemyType.FleshWorm
	else:
		return Enums.EnemyType.Punk

func _pick_enemy_medium() -> int:
	var r:float = randf()
	if r > 0.8:
		return Enums.EnemyType.Spider
	elif r > 0.6:
		return Enums.EnemyType.Cyclops
	elif r > 0.5:
		return Enums.EnemyType.FleshWorm
	else:
		return Enums.EnemyType.Punk

func _pick_enemy_easy() -> int:
	var r:float = randf()
	if r > 0.7:
		return Enums.EnemyType.FleshWorm
	else:
		return Enums.EnemyType.Punk

func _get_next_enemy_type(waveCount) -> int:
	if waveCount < 3:
		return _pick_enemy_easy()
	elif waveCount < 6:
		return _pick_enemy_medium()
	return _pick_enemy_hard()

func _tick_spawning(_delta:float) -> void:
	if _mobSpawnTick <= 0.0 && _killCount < _killTarget:
		_mobSpawnTick = 0.1
		if _activeMobIds.size() < _max_mob_count():
			var t:Transform = pick_spawn_point()
			var mob = Ents.create_mob(_get_next_enemy_type(_eventCount), t, true)
			mob.force_awake()
			var childId:int = mob.get_node("Entity").id
			_activeMobIds.push_back(childId)
		pass
	else:
		_mobSpawnTick -= _delta
