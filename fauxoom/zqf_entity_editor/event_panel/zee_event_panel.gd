extends Node

var _button_t = preload("res://zqf_entity_editor/event_panel/zee_event_item.tscn")
var _event_t = preload("res://zqf_entity_editor/event_panel/zee_event_details.tscn")

@onready var _eventsEditRoot:Control = $event_edit
@onready var _addNewEvent:Button = $event_list/add_new_event
@onready var _eventListRoot:Control = $event_list
@onready var _eventListItems:Control = $event_list/event_list_items
@onready var _closeEditing:Button = $close_event_edit

var _exampleEvents = [
	{
		name = "event_start",
		actions = [
			{
				"message": "on",
				"targets": [ "foo", "bar" ]
			},
			{
				"message": "",
				"targest": [ "fullpack1" ]
			}
		]
	}
]

enum EventEditMode {
	List,
	Edit
}

var _mode = EventEditMode.List
var _currentEditEvent = null

func _ready() -> void:
	_addNewEvent.connect("pressed", self, "_on_add_new_event")
	_closeEditing.connect("pressed", self, "_on_stop_editing_event")
	_show_list()

func _on_stop_editing_event() -> void:
	var items = _eventListItems.get_children()
	for item in items:
		item.refresh()
	_show_list()
	pass

func read(dict:Dictionary) -> void:
	pass

func write() -> Dictionary:
	return {}

func _show_list(_eventFilter:String = "") -> void:
	_closeEditing.visible = false
	_eventsEditRoot.visible = false
	_eventListRoot.visible = true
	if _currentEditEvent:
		_currentEditEvent.visible = false
		_currentEditEvent = null

func _edit_event(newEditEvent) -> void:
	_closeEditing.visible = true
	_eventsEditRoot.visible = true
	_eventListRoot.visible = false
	if _currentEditEvent != null:
		_currentEditEvent.visible = false
		_currentEditEvent = null
	_currentEditEvent = newEditEvent
	_currentEditEvent.visible = true
	_currentEditEvent.on_selected_for_edit()
	

func _on_event_item_action(item, action) -> void:
	
	if action == "delete":
		_eventsEditRoot.remove_child(item.eventDetails)
		_eventListItems.remove_child(item)
		print("Event item " + str(item.eventDetails.get_event_name()) + " action: " + str(action))
	else:
		_edit_event(item.eventDetails)
	pass

func _on_add_new_event() -> Object:
	# create event
	var ev = _event_t.instance()
	_eventsEditRoot.add_child(ev)
	#ev.visible = false
	# add button for editing
	var button = _button_t.instance()
	_eventListItems.add_child(button)
	button.refresh(ev)
	button.connect("action", self, "_on_event_item_action")
	return ev
