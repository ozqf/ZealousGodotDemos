extends Control

const EdEnums = preload("res://zqf_entity_editor/zee_enums.gd")
var _button_t = preload("res://zqf_entity_editor/ui/zee_button.tscn")

onready var _currentTagsRoot:Control = $zee_edit_tags_panel/current_tags
onready var _availableTagsRoot:Control = $zee_edit_tags_panel/available_tags

var _proxy:ZEEEntityProxy = null
var _selectedFieldName:String = "tagcsv"
var _dirty:bool = true
var _active:bool = false

func _ready() -> void:
	add_to_group(EdEnums.GROUP_NAME)
	set_active(false)
	$mouse_entered.init($zee_edit_tags_panel, $ColorRect)

func set_active(flag:bool) -> void:
	_active = flag
	self.visible = _active

func _refresh() -> void:
	_dirty = false
	# delete current buttons
	for child in _currentTagsRoot.get_children():
		child.queue_free()
	for child in _availableTagsRoot.get_children():
		child.queue_free()
	
	# build new buttons
	var tagsPool:PoolStringArray = _proxy.get_tags_field(_selectedFieldName)
	var tags:Array = Array(tagsPool)
	for tag in tags:
		_add_button(_currentTagsRoot, tag, tag, "_on_clicked_current_tag")
	var globalTagsPool = Ents.build_global_tag_list()
	var globalTags = Array(globalTagsPool)
	for tag in globalTags:
		if ZqfUtils.pool_string_find(tags, tag) == -1:
			_add_button(_availableTagsRoot, tag, tag, "_on_clicked_current_tag")

func _add_button(_parent:Control, name:String, label:String, callbackName) -> void:
	var obj = _button_t.instance()
	_parent.add_child(obj)
	obj.connect("clicked", self, callbackName)
	obj.name = name
	obj.text = label

func _on_clicked_current_tag(button) -> void:
	print("Clicked " + str(button.text))
	# _proxy.

func zee_on_new_entity_proxy(newProxy) -> void:
	_proxy = newProxy
	_dirty = true
	print("Tags edit - saw new proxy")
	set_active(true)
	_refresh()

func zee_on_clear_entity_selection() -> void:
	_proxy = null
	set_active(false)

func zee_on_select_edit_field(field:Dictionary, proxy:ZEEEntityProxy) -> void:
	proxy.get_fields()
	print("Tags edit - saw new field")
	pass
