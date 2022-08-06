extends Node

const EdEnums = preload("res://zqf_entity_editor/zee_enums.gd")

# var _ent_t = preload("res://zqf_entity_editor/zee_entity.tscn")
var _proxy_t = preload("res://zqf_entity_editor/zee_point_entity_proxy.tscn")

var _entsRoot:Spatial

func _ready() -> void:
	# listening to game group to track new entities!
	add_to_group(Groups.ENTS_GROUP_NAME)
	pass

func zee_ent_list_init(entsRoot:Spatial):
	_entsRoot = entsRoot

func on_restored_entity(prefab, prefabDef) -> void:
	var ent = prefab.get_node(prefabDef.entNodePath)
	create_entity_proxy(prefab, prefabDef, ent)

func scan_for_static_entities() -> void:
	var staticEnts = get_tree().get_nodes_in_group(Groups.STATIC_ENTS_GROUP_NAME)
	var numStatic:int = staticEnts.size()
	print("ZEE - restore finished - found " + str(numStatic) + " static ents")
	for ent in staticEnts:
		var proxy = create_entity_proxy(ent.get_parent(), {}, ent)
		proxy.isStatic = true

func create_entity_proxy(prefab, prefabDef, _ent) -> ZEEEntityProxy:
	var proxy = _proxy_t.instance()
	prefab.add_child(proxy)
	proxy.set_prefab(prefab, prefabDef)
	var grp:String = EdEnums.GROUP_NAME
	var fn:String = EdEnums.FN_ON_CREATED_NEW_ENTITY
	get_tree().call_group(grp, fn, proxy)
	return proxy

func refresh_entity_widgets() -> void:
	var numEnts:int = _entsRoot.get_child_count()
	var ents = _entsRoot.get_children()
	pass

func create_entity_at(pos:Vector3, prefabDef, prefabName) -> void:
	print("Create a " + str(prefabName) + " ent at " + str(pos))
	var prefab = prefabDef.prefab.instance()
	# check it has an entity, if not, we forgot something!
	var ent = prefab.get_node(prefabDef.entNodePath)
	if ent == null || !(ent is Entity):
		print("Warning: prefab " + prefabName + " has no Entity node")
		return
	
	_entsRoot.add_child(prefab)

	# add entity proxy for widgets etc
	var proxy:ZEEEntityProxy = create_entity_proxy(prefab, prefabDef, ent)
	proxy.set_prefab_position(pos)

func get_entity_count() -> int:
	return _entsRoot.get_child_count()
