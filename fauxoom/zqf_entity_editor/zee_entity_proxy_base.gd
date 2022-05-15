extends Spatial
class_name ZEEEntityProxy

var _prefab
var _prefabDef
var selfName:String = ""
var _data:Dictionary

func set_prefab(prefab, prefabDef) -> void:
	_prefab = prefab
	_prefabDef = prefabDef

	_data = {}
	if prefab.has_method("get_editor_info"):
		_data = prefab.get_editor_info()

func zee_refresh_fields() -> void:
	if _prefab.has_method("refresh_editor_info"):
		_prefab.refresh_editor_info(_data)

func set_field(fieldName:String, fieldValue:String) -> void:
	print("Proxy field " + fieldName + " changed: " + str(fieldValue))
	_data.fields[fieldName].value = fieldValue
	zee_refresh_fields()

func get_fields() -> Dictionary:
	if _data && _data.has("fields"):
		return _data.fields
	return ZqfUtils.EMPTY_DICT

func delete_prefab() -> void:
	_prefab.queue_free()
	pass

func get_label() -> String:
	if _data.has("selfName"):
		return _prefabDef.name + ": " + _data.selfName
	else:
		return _prefabDef.name
