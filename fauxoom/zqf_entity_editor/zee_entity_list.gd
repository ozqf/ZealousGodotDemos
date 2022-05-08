extends Node

var _ent_t = preload("res://zqf_entity_editor/zee_entity.tscn")
var _proxy_t = preload("res://zqf_entity_editor/zee_point_entity_proxy.tscn")

var _entsRoot:Spatial

func clear_all_ents() -> void:
	var entsNode = _entsRoot.get_children()
	var entsCount:int = entsNode.size()
	for i in range(0, entsCount):
		var ent = entsNode[i]
		ent.queue_free()

	pass

func zee_ent_list_init(entsRoot:Spatial):
	_entsRoot = entsRoot

func create_entity_at(pos:Vector3, prefabDef, prefabName) -> void:
	print("Create a " + str(prefabName) + " ent at " + str(pos))
	var prefab = prefabDef.prefab.instance()
	# check it has an entity, if not, we forgot something!
	var ent = prefab.get_node(prefabDef.entNodePath)
	if ent == null || !(ent is Entity):
		print("Warning: prefab " + prefabName + " has no Entity node")
		return
	var proxy = _proxy_t.instance()
	prefab.add_child(proxy)
	_entsRoot.add_child(prefab)
	prefab.global_transform.origin = pos
	if prefab.has_method("get_editor_info"):
		proxy.set_entity_info(prefab.get_editor_info(), ent)
	else:
		print("Warning: Instance has no editor info")
		proxy.set_entity_info(ZqfUtils.EMPTY_DICT, ent)

# func write_ents_list():
# 	var results = []
# 	var entsNode = _entsRoot.get_children()
# 	var entsCount:int = entsNode.size()
# 	for i in range(0, entsCount):
# 		var ent = entsNode[i]
# 		results.push_back(ent.write())
# 	return results

# func read_ents_list(_entsArray):
# 	clear_all_ents()

func get_entity_count() -> int:
	return _entsRoot.get_child_count()
