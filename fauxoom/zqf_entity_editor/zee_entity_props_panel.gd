extends Control

const EdEnums = preload("res://zqf_entity_editor/zee_enums.gd")

var _prop_field_t = preload("res://zqf_entity_editor/zee_ui_entity_field.tscn")

onready var _nameInput:ZEEUIField = $bg/props_scroll_area/props_container/global_props/selfName
onready var _targetsInput:ZEEUIField = $bg/props_scroll_area/props_container/global_props/targets

onready var _dynamicProps:Control = $bg/props_scroll_area/props_container/dynamic_props

var _proxy:ZEEEntityProxy = null
var _on:bool = false

func _ready():
	self.add_to_group(EdEnums.GROUP_NAME)
	var _r = _nameInput.connect("field_changed", self, "on_field_changed")
	_r = _targetsInput.connect("field_changed", self, "on_field_changed")
	_nameInput.visible = false
	_targetsInput.visible = false
	pass

func _refresh() -> void:
	_delete_all_fields()
	if !_on || _proxy == null:
		self.visible = false
		return
	# we have stuff to show and setup to do
	self.visible = true
	var fieldDefs:Dictionary = _proxy.get_fields()
	var keys = fieldDefs.keys()
	if keys.size() == 0:
		# ...nevermind then!
		self.visible = false
		return
	for key in keys:
		var def = fieldDefs[key]
		var field:ZEEUIField = _prop_field_t.instance()
		_dynamicProps.add_child(field)
		field.init(def.name, def.label, def.value)
		field.connect("field_changed", self, "on_field_changed")

func _delete_all_fields() -> void:
	for child in _dynamicProps.get_children():
		child.queue_free()
	pass

func zee_on_root_mode_changed(newMode) -> void:
	_on = newMode == EdEnums.RootMode.Select
	_refresh()

func zee_on_global_enabled() -> void:
	zee_on_clear_entity_selection()

func zee_on_global_disabled() -> void:
	zee_on_clear_entity_selection()

func zee_on_clear_entity_selection() -> void:
	_proxy = null
	print("Props panel - clearing proxy")
	_refresh()

func zee_on_new_entity_proxy(newProxy) -> void:
	if newProxy == null || !(newProxy is ZEEEntityProxy):
		zee_on_clear_entity_selection()
		return
	_proxy = newProxy as ZEEEntityProxy
	print("Props panel - got new proxy - " + str(_proxy))
	_refresh()

func create_ui_field():
	return _prop_field_t.instance()

func on_field_changed(fieldName:String, value) -> void:
	if _proxy == null:
		print("Field " + fieldName + " changed but no proxy!")
		return
	_proxy.set_field(fieldName, value)
