extends Spatial
class_name ZEEEntityProxy

const DIRTY_REFRESH_TIME:float = 0.25

var _prefab
var _prefabDef
var selfName:String = ""
var _data:Dictionary

var _dirty:bool = false
var _dirtyTick:float = 0.0

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
		elif field.type == "xform":
			save[key] = ZqfUtils.transform_to_dict(_prefab.global_transform)
		else:
			save[key] = field.value
	return save

func zee_refresh_fields() -> void:
	print("Proxy - dirty")
	_dirty = true
	_dirtyTick = DIRTY_REFRESH_TIME

func _refresh() -> void:
	print("Proxy - refresh")
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

func _process(_delta:float) -> void:
	if _dirty:
		_dirtyTick -= _delta
		if _dirtyTick <= 0:
			_dirty = false
			_refresh()
