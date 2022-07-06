extends Control

const EdEnums = preload("res://zqf_entity_editor/zee_enums.gd")
var _button_t = preload("res://zqf_entity_editor/ui/zee_button.tscn")

onready var _currentTagsRoot:Control = $zee_edit_tags_panel/current_tags
onready var _availableTagsRoot:Control = $zee_edit_tags_panel/available_tags

onready var _addTagButton:Button = $zee_edit_tags_panel/add_tag/Button
onready var _addTagLine:LineEdit = $zee_edit_tags_panel/add_tag/LineEdit

var _proxy:ZEEEntityProxy = null
var _selectedFieldName:String = "tagcsv"
var _dirty:bool = true
var _active:bool = false

var _editTags:PoolStringArray = []

func _ready() -> void:
	add_to_group(EdEnums.GROUP_NAME)
	set_active(false)
	_addTagButton.connect("pressed", self, "_on_add_new_tag")
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
	var tagsPool:PoolStringArray = _proxy.get_tags_field_value(_selectedFieldName)
	var tags:Array = Array(tagsPool)
	for tag in tags:
		_add_button(_currentTagsRoot, tag, tag, "_on_clicked_current_tag")
	var globalTagsPool = Ents.build_global_tag_list()
	var globalTags = Array(globalTagsPool)
	for tag in globalTags:
		if ZqfUtils.pool_string_find(tags, tag) == -1:
			_add_button(_availableTagsRoot, tag, tag, "_on_clicked_global_tag")

func _add_button(_parent:Control, name:String, label:String, callbackName) -> void:
	var obj = _button_t.instance()
	_parent.add_child(obj)
	obj.connect("clicked", self, callbackName)
	obj.name = name
	obj.text = label

# func _has_edit_tag(query:String) -> bool:
# 	var i:int = _editTags.find(query, 0)
# 	if i

func _add_tag(tag:String) -> void:
	var i:int = Array(_editTags).find(tag, 0)
	if i == -1:
		_editTags.push_back(tag)
		print("add new tag: " + str(tag))
	else:
		print("Already have a tag " + str(tag))
	_proxy.set_field(_selectedFieldName, _editTags.join(","))
	_refresh()

func _delete_tag(tag:String) -> void:
	var i:int = Array(_editTags).find(tag, 0)
	if i == -1:
		return
	_editTags.remove(i)
	_proxy.set_field(_selectedFieldName, _editTags.join(","))
	_refresh()

func _on_add_new_tag() -> void:
	var newTag:String = _addTagLine.text
	_addTagLine.text = ""
	_add_tag(newTag)

func _on_clicked_current_tag(button) -> void:
	var tag:String = button.text
	print("Clicked current tag " + str(button.text))
	_delete_tag(tag)

func _on_clicked_global_tag(button) -> void:
	print("Clicked global tag " + str(button.text))
	_add_tag(button.text)

func zee_on_new_entity_selection(_newProxy) -> void:
	#_proxy = newProxy
	#_dirty = true
	#print("Tags edit - saw new proxy")
	#set_active(true)
	#_refresh()
	pass

func zee_on_clear_entity_selection() -> void:
	_proxy = null
	set_active(false)

func zee_on_edit_tags_field(field:Dictionary, newProxy:ZEEEntityProxy) -> void:
	_selectedFieldName = field.name
	_proxy = newProxy
	_dirty = true
	_editTags = field.value.split(",")
	set_active(true)
	_refresh()
	print("Tags edit - saw new field")
	pass
