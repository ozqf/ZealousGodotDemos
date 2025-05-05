extends Node

var _action_t = preload("res://zqf_entity_editor/event_panel/zee_event_action.tscn")

@onready var _nameEdit:LineEdit = $event_name_edit
@onready var _actionsRoot:Control = $actions_list
@onready var _addNewAction:Button = $add_action

func _ready() -> void:
	_addNewAction.connect("pressed", self, "_on_add_new_action")

func get_event_name() -> String:
	return _nameEdit.text

func _on_add_new_action() -> Object:
	var action = _action_t.instance()
	_actionsRoot.add_child(action)
	return action

func on_selected_for_edit() -> void:
	_nameEdit.grab_focus()

func read(_dict:Dictionary) -> void:
	
	pass

func write() -> Dictionary:
	return {

	}
