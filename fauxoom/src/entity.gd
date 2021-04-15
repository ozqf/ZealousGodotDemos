# Entity class handles boilerplate for gameplay objects. assigning Ids
# saving, loading etc. Should be added as a child of the root of
# the actual entity itself
# Relies on the entities (Ents) autoloaded service to be present
extends Node
class_name Entity

signal entity_append_state(dict)
signal entity_restore_state(dict)
signal entity_trigger()

# objects which are static should be loaded at the start of the map
# (usually as part of an embedded scene file) and NEVER deleted
# until map change.
export var isStatic:bool = false
# dynamic entities may or may not exist at any given time. in order to
# restore a previously deleted entity, we must know what prefab it was
# if this isn't set loading will not work!
export var prefabName:String = ""
export var selfName:String = ""
export var triggerTargetName:String = ""
var id:int = 0
var _rootOverride:Node = null

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
		var prefab = Game.get_entity_prefab(prefabName)
		assert(prefab != null)
	# print("Ent " + get_parent().name + " id: " + str(id))

# set this if getting from this entity component node to the actual root of the prefab
# is not as simple as get_parent()
func set_root_override(root:Node) -> void:
	_rootOverride = root

func get_root_node() -> Node:
	if _rootOverride:
		return _rootOverride
	return get_parent()

func on_trigger_entities(target:String) -> void:
	if target == "":
		return
	if selfName == target:
		# trigger!
		emit_signal("entity_trigger")

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
		id = id,
		selfName = selfName,
		triggerTargetName = triggerTargetName,
	}
	emit_signal("entity_append_state", dict)
	return dict

func restore_state(dict:Dictionary) -> void:
	assert(dict)
	selfName = dict.selfName
	triggerTargetName = dict.triggerTargetName
	id = dict.id
	emit_signal("entity_restore_state", dict)
