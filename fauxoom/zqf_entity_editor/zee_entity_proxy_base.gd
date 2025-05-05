# Class that attaches to a non-editor related object and handles
# editor manipulation of the object.
# Objects must have methods to @export their fields etc to the proxy
# or it can't do very much
extends Node3D
class_name ZEEEntityProxy

const EdEnums = preload("res://zqf_entity_editor/zee_enums.gd")

const DIRTY_REFRESH_TIME:float = 0.25

var isStatic:bool = false

var _prefab
var _prefabDef
var selfName:String = ""
var _data:Dictionary

var _dirty:bool = false
var _dirtyTick:float = 0.0

func _ready() -> void:
	add_to_group(EdEnums.GROUP_ENTITY_PROXIES)
	pass

func _patch_fields(fields:Dictionary) -> void:
	var keys = fields.keys()
	for key in keys:
		var field = fields[key]
		if !field.has("name"):
			field.name = key
		if !field.has("label"):
			field.label = field.name

func set_prefab(prefab, prefabDef) -> void:
	_prefab = prefab
	_prefabDef = prefabDef
	_refresh_self_scale()

	_data = {}
	if prefab.has_method("get_editor_info"):
		_data = prefab.get_editor_info()
		if _data.has("fields"):
			_patch_fields(_data.fields)

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
	#print("Proxy - dirty")
	_dirty = true
	_dirtyTick = DIRTY_REFRESH_TIME

func _refresh() -> void:
	#print("Proxy - refresh")
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

func get_presets() -> Array:
	if _data.has("presets"):
		print("Providing " + str(_data.presets.size()) + " presets")
		return _data.presets
	else:
		print("Prefab has not presets")
		return ZqfUtils.EMPTY_ARRAY

func apply_preset(presetName:String) -> void:
	if !_prefab.has_method("apply_preset"):
		print("Prefab has no apply preset function")
		return
	_prefab.apply_preset(presetName)

func get_field(fieldName:String) -> Dictionary:
	if !_data || !_data.has("fields"):
		return ZqfUtils.EMPTY_DICT
	if !_data.fields.has(fieldName):
		return ZqfUtils.EMPTY_DICT
	var field = _data.fields[fieldName]
	return field

func get_tags_field_value(fieldName:String) -> PackedStringArray:
	if !_data || !_data.has("fields"):
		return PackedStringArray()
	if !_data.fields.has(fieldName):
		return PackedStringArray()
	var field = _data.fields[fieldName]
	if field.type != EdEnums.FIELD_TYPE_TAGS:
		return PackedStringArray()
	return field.value.split(",", false, 0)

func get_tag_fields():
	var result = []
	if !_data || !_data.has("fields"):
		return PackedStringArray()
	for fieldName in _data.fields:
		var field = _data.fields[fieldName]
		if field.type == EdEnums.FIELD_TYPE_TAGS:
			result.push_back(field)
	return result

func delete_prefab() -> void:
	var grp:String = EdEnums.GROUP_NAME
	var fn:String = EdEnums.FN_REMOVED_ENTITY_PROXY
	get_tree().call_group(grp, fn, self)
	_prefab.queue_free()

func set_prefab_position(pos:Vector3) -> void:
	if _prefab.has_method("set_position"):
		_prefab.set_position(pos)
	else:
		_prefab.global_transform.origin = pos

func set_prefab_yaw(degrees:float) -> void:
	if _data.rotatable == false:
		return
	
	if _prefab.has_method("zee_set_yaw_degrees"):
		_prefab.zee_set_yaw_degrees(degrees)
		return
	_prefab.rotation_degrees = Vector3(0, degrees, 0)

func get_prefab_yaw_degrees() -> float:
	return _prefab.rotation_degrees.y

func get_prefab_transform() -> Transform3D:
	return _prefab.global_transform

func get_prefab_basis() -> Basis:
	return _prefab.global_transform.basis

func get_prefab_scale() -> Vector3:
	return _prefab.scale

func get_prefab_type() -> String:
	return _get_prefab_name()
	#return _prefabDef.name

func _get_prefab_name() -> String:
	if !_prefabDef:
		return "<static>"
	return _prefabDef.name

func _refresh_self_scale() -> void:
	var newScale:Vector3 = _prefab.scale
	var selfScale:Vector3 = Vector3()
	selfScale.x = 1.0 / newScale.x
	selfScale.y = 1.0 / newScale.y
	selfScale.z = 1.0 / newScale.z
	self.scale = selfScale

func set_prefab_scale(newScale:Vector3) -> void:
	if _data.scalable == false:
		return
	_prefab.scale = newScale
	_refresh_self_scale()

func get_label() -> String:
	
	if _data.has("selfName"):
		return _get_prefab_name() + ": " + _data.selfName
	else:
		return _get_prefab_name()

func is_on_screen() -> bool:
	var pos:Vector3 = get_parent().global_transform.origin
	var cam:Transform3D = get_viewport().get_camera().global_transform
	var toCamera:Vector3 = cam.origin - pos
	if (cam.basis.z).dot(toCamera) > 0:
		return true
	else:
		return false

func get_screen_position() -> Vector2:
	var pos:Vector3 = get_parent().global_transform.origin
	return get_viewport().get_camera().unproject_position(pos)

func _process(_delta:float) -> void:
	if _dirty:
		_dirtyTick -= _delta
		if _dirtyTick <= 0:
			_dirty = false
			_refresh()
