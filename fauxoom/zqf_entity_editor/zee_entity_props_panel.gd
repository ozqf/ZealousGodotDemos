extends Control

const EdEnums = preload("res://zqf_entity_editor/zee_enums.gd")

var _prop_field_t = preload("res://zqf_entity_editor/zee_ui_entity_field.tscn")

onready var _nameInput:LineEdit = $ColorRect/VBoxContainer/name_input
onready var _targetsInput:LineEdit = $ColorRect/VBoxContainer/targets_input

var _proxy:ZEEEntityProxy = null
var _on:bool = false

func _ready():
	self.add_to_group(EdEnums.GROUP_NAME)
	var _r = _nameInput.connect("text_changed", self, "_on_text_changed")
	_r = _targetsInput.connect("text_changed", self, "_on_targets_changed")
	pass

func _refresh() -> void:
	if _on && _proxy != null:
		self.visible = true
	else:
		self.visible = false

func zee_on_root_mode_changed(newMode) -> void:
	_on = newMode == EdEnums.RootMode.Select
	_refresh()

func zee_on_global_enabled() -> void:
	pass

func zee_on_global_disabled() -> void:
	pass

func zee_on_new_entity_proxy(newProxy) -> void:
	if newProxy == null || !(newProxy is ZEEEntityProxy):
		_proxy = null
		_refresh()
		return
	_proxy = newProxy as ZEEEntityProxy
	_refresh()

func create_ui_field():
	return _prop_field_t.instance()

func _on_name_changed(_txt:String) -> void:
	pass

func _on_targets_changed(_txt:String) -> void:
	pass
