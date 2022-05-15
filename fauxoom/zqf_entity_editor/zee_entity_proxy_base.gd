extends Spatial
class_name ZEEEntityProxy

var _prefab
var _prefabDef
var selfName:String = ""
var _data:Dictionary
#var _ent:Entity

# func set_entity_info(_info:Dictionary, ent:Entity) -> void:
# 	_ent = ent
# 	if !_info:
# 		# no info passed in
# 		return
# 	# init
# 	pass

func set_prefab(prefab, prefabDef) -> void:
	_prefab = prefab
	_prefabDef = prefabDef

	_data = {}
	if prefab.has_method("get_editor_info"):
		_data = prefab.get_editor_info()

func refresh_fields() -> void:
	if _prefab.has_method("refresh_editor_fields"):
		_prefab.refresh_editor_fields(_data)

func get_label() -> String:
	return _prefabDef.name + ": " + _data.selfName
 