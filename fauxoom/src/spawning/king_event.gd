extends Spatial

onready var _ent:Entity = $Entity

var _spawnPointTagsShared:EntTagSet
var _gateTags:EntTagSet

var _spawnPointEnts = []

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group(Groups.ENTS_GROUP_NAME)
	var _result = _ent.connect("entity_append_state", self, "append_state")
	_result = _ent.connect("entity_restore_state", self, "restore_state")
	_spawnPointTagsShared = Game.new_tag_set()
	_gateTags = Game.new_tag_set()
	
	if Main.is_in_game():
		visible = false

func ents_post_load() -> void:
	_spawnPointEnts = []
	if _spawnPointTagsShared.tag_count() >= 0:
		var tags = _spawnPointTagsShared.get_tags()
		for tag in tags:
			_spawnPointEnts.append_array(Ents.find_dynamic_entities(tag, "info_point"))
	print("King event found " + str(_spawnPointEnts.size()) + " spawn points")

func king_event_start() -> void:
	print("King event - start")
	var tags = _gateTags.get_tags()
	var tree = get_tree()
	var grp:String = Groups.ENTS_GROUP_NAME
	var fn:String = Groups.ENTS_FN_TRIGGER_ENTITIES
	for tag in tags:
		tree.call_group(grp, fn, tag, "on", ZqfUtils.EMPTY_DICT)
	pass

func king_event_stop() -> void:
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
	# visible = true
	# return {
	# 	prefab = _ent.prefabName,
	# 	fields = {
	# 		spts = { "name": "spts", "value": _spawnPointTagsShared.get_csv(), "type": "tags" },
	# 		gateTags = { "name": "gateTags", "value": _gateTags.get_csv(), "type": "tags" }
	# 	}
	# }
	var info = _ent.get_editor_info_base()
	ZEEMain.create_field(info.fields, "spts", "Spawn Point tags", "tags", _spawnPointTagsShared.get_csv())
	ZEEMain.create_field(info.fields, "gateTags", "Gate tags", "tags", _gateTags.get_csv())
	return info
