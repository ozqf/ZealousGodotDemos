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

func _write_save_from_info(data:Dictionary) -> Dictionary:
	var save:Dictionary = {}
	var fields = data.fields
	var keys = data.fields.keys()
	for key in keys:
		#var key = field.name
		var field = data.fields[key]
		if field.type == "int":
			save[key] = int(field.value)
		elif field.type == "float":
			save[key] = float(field.value)
		elif field.type == "position":
			save[key] = ZqfUtils.v3_to_dict(_prefab.global_transform.origin)
		elif field.type == "flag":
			save[key] = ZqfUtils.parse_bool(field.value)
		else:
			save[key] = field.value
	return save

func zee_refresh_fields() -> void:
	# if _prefab.has_method("refresh_editor_info"):
	# 	_prefab.refresh_editor_info(_data)
	var save:Dictionary = _write_save_from_info(_data)
	if _prefab.has_method("restore_from_editor"):
		_prefab.restore_from_editor(save)
	else:
		print("Entity has no editor restore function!")

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
