# Entity class handles boilerplate for gameplay objects. assigning Ids
# saving, loading etc. Should be added as a child of the root of
# the actual entity itself
# Relies on the entities (Ents) autoloaded service to be present
extends Node
class_name Entity

static func get_entity(obj) -> Entity:
	if !ZqfUtils.is_obj_safe(obj) || !obj.has_method("get_entity"):
		return null
	return obj.get_entity() as Entity

signal entity_append_state(dict)
signal entity_restore_state(dict)
signal entity_trigger(message, dict)

# objects which are static should be loaded at the start of the map
# (usually as part of an embedded scene file) and NEVER deleted
# until map change.
export var isStatic:bool = false
# dynamic entities may or may not exist at any given time. in order to
# restore a previously deleted entity, we must know what prefab it was
# if this isn't set loading will not work!
export var prefabName:String = ""
# the name of this entity to respond to trigger events
export var selfName:String = ""
# the space separated list of other entities to trigger when this
# entity's trigger event occurs
export var triggerTargetName:String = ""
# tags are for grouping entities for querying
export var tagCSV:String = ""
# id to identify this entity. negative for static, positive for dynamic
var id:int = 0
var _rootOverride:Node = null
var _tags:PoolStringArray = PoolStringArray()

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group(Groups.GAME_GROUP_NAME)
	add_to_group(Groups.ENTS_GROUP_NAME)
	var _r = connect("tree_entered", self, "_on_tree_entered")
	_r = connect("tree_exiting", self, "_on_exiting_tree")
	if isStatic:
		id = Ents.assign_static_id()
		add_to_group(Groups.STATIC_ENTS_GROUP_NAME)
	else:
		id = Ents.assign_dynamic_id()
		add_to_group(Groups.DYNAMIC_ENTS_GROUP_NAME)
		# check we have a valid entity def specified or we can't save!
		var prefab = Ents.get_prefab_def(prefabName)
		assert(prefab != null)
	_refresh_tag_list()
	# print("Ent " + get_parent().name + " id: " + str(id))

func get_label() -> String:
	if selfName != "":
		return selfName
	return get_parent().name

func get_ent_transform() -> Transform:
	return get_parent().global_transform

func _refresh_tag_list() -> void:
	_tags = tagCSV.split(",", false, 0)

# func add_runtime_tag(tag:String) -> void:
# 	_tags.push_back(tag)

func has_tag(queryTag:String) -> bool:
	for tag in _tags:
		if tag == queryTag:
			return true
	return false

func get_editor_info_base() -> Dictionary:
	var info = {
		"prefab": self.prefabName,
		"scalable": false,
		"rotatable": false,
		"fields": {}
	}
	ZEEMain.create_field(info.fields, "sn", "Self Name", "text", self.selfName)
	ZEEMain.create_field(info.fields, "tcsv", "Target CSV", "text", self.triggerTargetName)
	ZEEMain.create_field(info.fields, "tagcsv", "Self Tags CSV", "tags", tagCSV)
	return info

func get_editor_info_empty() -> Dictionary:
	var info = {
		"prefab": self.prefabName,
		"scalable": false,
		"rotatable": false,
		"fields": {}
	}
	# ZEEMain.create_field(info.fields, "tagcsv", "Self Tags CSV", "tags", tagCSV)
	return info

func append_global_tags(tagDict:Dictionary) -> void:
	for tag in _tags:
		if !tagDict.has(tag):
			tagDict[tag] = ""

# set this if getting from this entity component node to the actual root of the prefab
# is not as simple as get_parent()
func set_root_override(root:Node) -> void:
	_rootOverride = root

func get_root_node() -> Node:
	if _rootOverride:
		return _rootOverride
	return get_parent()

func attach_command_signals(root:Node) -> void:
	var _result = self.connect("entity_append_state", root, "append_state")
	_result = self.connect("entity_restore_state", root, "restore_state")

func on_trigger_entities(target:String, message:String, dict:Dictionary) -> void:
	if target == "":
		return
	if selfName == target || self.has_tag(target):
		# trigger!
		# print(prefabName + " " + selfName + " triggered")
		emit_signal("entity_trigger", message, dict)

func trigger() -> void:
	# when triggering was by signals...
	# emit_signal("trigger", ZqfUtils.EMPTY_STR, ZqfUtils.EMPTY_DICT)
	Interactions.triggerTargets(get_tree(), triggerTargetName)

#func trigger_tags(message:String) -> void:
#	for tag in _tags:
#		Interactions.triggerTargetsWithParams(get_tree(), _tags, message, ZqfUtils.EMPTY_DICT)

func trigger_tag_set(tags:PoolStringArray, message:String) -> void:
	Interactions.triggerTargetsWithParams(get_tree(), tags, message, ZqfUtils.EMPTY_DICT)

func _on_exiting_tree() -> void:
	# deregister entity...?
	pass

func write_state() -> Dictionary:
	# if this entity isn't static we must know what prefab to use
	# when restoring this entity!
	if !isStatic:
		assert(prefabName != "")
	var dict = {
		prefab = prefabName,
		id = id
	}
	
	var tagTxt:String
	if !isStatic:
		dict.sn = selfName
		dict.tcsv = triggerTargetName
		dict.tagcsv = _tags.join(",")
	emit_signal("entity_append_state", dict)
	return dict

func restore_state(dict:Dictionary) -> void:
	assert(dict)
	if !isStatic:
		selfName = ZqfUtils.safe_dict_s(dict, "sn", "")
		triggerTargetName = ZqfUtils.safe_dict_s(dict, "tcsv", "")
		if dict.has("tagcsv"):
			tagCSV = dict.tagcsv
			_refresh_tag_list()
		# print("Restored trigger target name " + str(triggerTargetName))
	if dict.has("id"):
		id = dict.id
	
	emit_signal("entity_restore_state", dict)
