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
	#var temp = _templates[templateIndex]
	print("Create a " + str(prefabName) + " ent at " + str(pos))
	# var obj = _ent_t.instance()
	# _entsRoot.add_child(obj)
	# obj.global_transform.origin = pos
	# obj.templateName = template.name
	var ent = prefabDef.prefab.instance()
	var proxy = _proxy_t.instance()
	ent.add_child(proxy)
	_entsRoot.add_child(ent)
	ent.global_transform.origin = pos
	if ent.has_method("get_editor_info"):
		ent.get_editor_info()
	else:
		print("Warning: Instance has no editor info")

func write_ents_list():
	var results = []
	var entsNode = _entsRoot.get_children()
	var entsCount:int = entsNode.size()
	for i in range(0, entsCount):
		var ent = entsNode[i]
		results.push_back(ent.write())
	return results

func read_ents_list(_entsArray):
	clear_all_ents()

func get_entity_count() -> int:
	return _entsRoot.get_child_count()
