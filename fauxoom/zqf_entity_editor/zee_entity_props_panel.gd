extends Control

const EdEnums = preload("res://zqf_entity_editor/zee_enums.gd")

var _prop_field_t = preload("res://zqf_entity_editor/ui/zee_ui_entity_field.tscn")
var _prop_field_special_t = preload("res://zqf_entity_editor/ui/zee_ui_entity_field_special.tscn")

@onready var _nameInput:ZEEUIField = $bg/props_scroll_area/props_container/global_props/selfName
@onready var _targetsInput:ZEEUIField = $bg/props_scroll_area/props_container/global_props/targets

@onready var _dynamicProps:Control = $bg/props_scroll_area/props_container/dynamic_props
@onready var _presetButtons:Control = $bg/props_scroll_area/props_container/presets

var _proxy:ZEEEntityProxy = null
var _on:bool = false

func _ready():
	self.add_to_group(EdEnums.GROUP_NAME)
	var _r = _nameInput.connect("field_changed", self, "on_field_changed")
	_r = _targetsInput.connect("field_changed", self, "on_field_changed")
	_nameInput.visible = false
	_targetsInput.visible = false

func _refresh() -> void:
	_delete_all_fields()
	if !_on || _proxy == null:
		self.visible = false
		return
	# we have stuff to show and setup to do
	self.visible = true
	
	# add buttons for presets - if they are provided
	var presets = _proxy.get_presets()
	if presets.size() > 0:
		for preset in presets:
			# create a button to apply each preset
			var b = Button.new()
			b.name = preset
			b.text = preset
			_presetButtons.add_child(b)
			b.connect("pressed", self, "zee_on_apply_preset", [b.name])
	
	var fieldDefs:Dictionary = _proxy.get_fields()
	var keys = fieldDefs.keys()
	if keys.size() == 0:
		# ...nevermind then!
		if presets.size() == 0:
			# nothing to show at all
			self.visible = false
		return
	for key in keys:
		var def = fieldDefs[key]
		if def.type == "tags":
			var field:ZEEUIFieldSpecial = _prop_field_special_t.instance()
			_dynamicProps.add_child(field)
			field.init(def.name, def.label, def.value)
			field.connect("edit_special_field", self, "on_edit_special_field")
		else:
			var field:ZEEUIField = _prop_field_t.instance()
			_dynamicProps.add_child(field)
			field.init(def.name, def.label, def.value)
			field.connect("field_changed", self, "on_field_changed")

func _delete_all_fields() -> void:
	for child in _dynamicProps.get_children():
		child.queue_free()
	for child in _presetButtons.get_children():
		child.queue_free()

func zee_on_apply_preset(presetName:String) -> void:
	_proxy.apply_preset(presetName)

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

func zee_on_new_entity_selection(newProxy) -> void:
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

func on_edit_special_field(fieldName:String) -> void:
	if _proxy == null:
		print("Field " + fieldName + " clicked but no proxy!")
		return
	var field = _proxy.get_field(fieldName)
	if !field:
		return
	if field.type == EdEnums.FIELD_TYPE_TAGS:
		# print("Edit tags field " + fieldName)
		var grp = EdEnums.GROUP_NAME
		var fn = EdEnums.FN_EDIT_TAGS_FIELD
		get_tree().call_group(grp, fn, field, _proxy)
