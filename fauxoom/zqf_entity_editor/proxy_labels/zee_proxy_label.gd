extends Control

const EdEnums = preload("res://zqf_entity_editor/zee_enums.gd")

@onready var _label:Label = $Label
var _proxy:ZEEEntityProxy = null

func init(proxy) -> void:
	add_to_group(EdEnums.GROUP_NAME)
	_proxy = proxy
	_proxy.connect("tree_exiting", _on_subject_tree_exiting)
	_refresh()

func _on_subject_tree_exiting() -> void:
	zee_on_removed_entity_proxy(_proxy)

func zee_on_removed_entity_proxy(proxy) -> void:
	if _proxy == proxy:
		_proxy = null
		self.queue_free()

func _refresh() -> void:
	var field = _proxy.get_field("tagcsv")
	var type:String = _proxy.get_prefab_type()
	if !field:
		_label.text = type
		return
	var tagcsv = field.value
	if tagcsv == "":
		_label.text = type
		return
	_label.text = type + "\n" + tagcsv

func _process(_delta) -> void:
	if !ZqfUtils.is_obj_safe(_proxy):
		return
	if _proxy.is_on_screen():
		self.visible = true
		self.set_position(_proxy.get_screen_position())
	else:
		self.visible = false
