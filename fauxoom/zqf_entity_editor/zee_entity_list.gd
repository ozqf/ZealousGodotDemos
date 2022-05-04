extends Node

var _ent_t = preload("res://zqf_entity_editor/zee_entity.tscn")

var _entsRoot:Spatial

func _clear_all_ents() -> void:
	var entsNode = _entsRoot.get_children()
	var entsCount:int = entsNode.size()
	for i in range(0, entsCount):
		var ent = entsNode[i]
		ent.queue_free()

func zee_ent_list_init(entsRoot:Spatial):
	_entsRoot = entsRoot

func create_entity_at(pos:Vector3, template) -> void:
	#var temp = _templates[templateIndex]
	print("Create a " + str(template.label) + " ent at " + str(pos))
	var obj = _ent_t.instance()
	_entsRoot.add_child(obj)
	obj.global_transform.origin = pos
	obj.templateName = template.name

func write_ents_list():
	var results = []
	var entsNode = _entsRoot.get_children()
	var entsCount:int = entsNode.size()
	for i in range(0, entsCount):
		var ent = entsNode[i]
		results.push_back(ent.write())
	return results

func read_ents_list(_entsArray):
	_clear_all_ents()
