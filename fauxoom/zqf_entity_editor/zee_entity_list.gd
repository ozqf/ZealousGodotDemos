extends Node

var _ent_t = preload("res://zqf_entity_editor/zee_entity.tscn")
var _proxy_t = preload("res://zqf_entity_editor/zee_point_entity_proxy.tscn")

var _entsRoot:Spatial

func _ready() -> void:
	add_to_group(Groups.ENTS_GROUP_NAME)

func zee_ent_list_init(entsRoot:Spatial):
	_entsRoot = entsRoot

func on_restored_entity(prefab, prefabDef) -> void:
	var ent = prefab.get_node(prefabDef.entNodePath)
	create_entity_proxy(prefab, prefabDef, ent)
	pass

func create_entity_proxy(prefab, prefabDef, _ent) -> ZEEEntityProxy:
	var proxy = _proxy_t.instance()
	prefab.add_child(proxy)
	proxy.set_prefab(prefab, prefabDef)
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
