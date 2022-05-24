extends Node

const _empty_events:Dictionary = {
	"events": {}
}

export var eventsDict:Dictionary

var _data = {}

func _ready():
	clear()
	add_to_group(Groups.CONSOLE_GROUP_NAME)
	add_to_group(Groups.ENTS_GROUP_NAME)
	# var mapName = get_tree().current_scene.filename
	# var eventsPath:String = "res://maps/catacombs_01/events.tres"
	# if !ResourceLoader.exists(eventsPath):
	# 	print("No events file at " + str(eventsPath))
	# 	return
	# var data = ZqfUtils.load_dict_json_file(eventsPath)
	# _data = data
	# print("Read " + str(_data.events.size()) + " events")

func restore(_dict:Dictionary) -> void:
	print("EVENTS - load")
	_data = _dict

func write_state() -> Dictionary:
	print("EVENTS - save")
	return _data

func clear() -> void:
	_data = _empty_events

func add_event(eventName:String) -> Dictionary:
	var events = _data.events
	if events.has(eventName):
		print("Event " + str(eventName) + " already exists")
		return events[eventName]
	print("EVENTS - add " + str(eventName))
	events[eventName] = {
		"name": eventName,
		"actions": []
	}
	return events[eventName]

# adds an event action - also creates the event if it doesn't exist
# returns event dictionary
func add_action(eventName:String, actionType:String, targetName:String, message:String) -> Dictionary:
	var ev:Dictionary = add_event(eventName)
	var action = {
		"action": actionType,
		"targets": targetName,
		"message": message
	}
	ev.actions.push_back(action)
	return ev

func remove_action(eventName:String, actionIndex:int) -> Dictionary:
	print("Remove action " + str(actionIndex) + " from event " + str(eventName))
	return {}

func console_on_exec(_txt:String, _tokens:PoolStringArray) -> void:
	if _tokens[0] != "events":
		return
	if _tokens.size() == 1:
		print("Events - options: list, trigger, add, remove")
		return
	if _tokens[1] == "list":
		print(_print_events())
		return
	if _tokens[1] == "trigger" && _tokens.size() == 3:
		var eventName:String = _tokens[2]
		_fire_event(_data, eventName)
	if _tokens[1] == "add":
		if _tokens.size() < 6:
			print("Need 6 params: events add <eventName> <actionType> <target> <message>")
			return
		var ev = add_action(_tokens[2], _tokens[3], _tokens[4], _tokens[5])
		print(_print_event(ev))
	if _tokens[1] == "remove":
		if _tokens.size() < 4:
			print("Need 4 params: events remove <eventName> <actionIndex>")
			return
		remove_action(_tokens[2], int(_tokens[3]))
	pass

func _print_event(ev:Dictionary) -> String:
	if !ev:
		print("Event dict is empty")
	var txt = ""
	var numActions:int = ev.actions.size()
	txt += "Event " + str(ev.name) + " has " + str(numActions) + " actions" + "\n"
	for i in range(0, numActions):
		var action = ev.actions[i]
		txt += str(i) + ":\t" + str(action.action) + " / " + str(action.targets) + " / " + str(action.message) + "\n"
	return txt

func _print_events() -> String:
	var txt:String = ""
	if !_data.has("events"):
		return "No events found"
	var keys = _data.events.keys()
	txt += "Found " + str(keys.size()) + " events\n"
	for key in keys:
		var ev = _data.events[key]
		txt += _print_event(ev)
	return txt

func _fire_event(data, eventName:String) -> void:
	if !_data.has("events"):
		return
	if !data.events.has(eventName):
		return
	print("Fire event " + str(eventName))
	var ev = data.events[eventName]
	for j in range(0, ev.actions.size()):
		var action = ev.actions[j]
		if !action.has("action"):
			print("Action has no action type field")
			return
		var actionType = action.action
		if actionType != "trigger":
			print("Action in event " + str(eventName) + " as unsupported action type " + str(actionType))
			return
		var message:String = ""
		if action.has("message"):
			message = str(action.message)
		var params:Dictionary = ZqfUtils.EMPTY_DICT
		if action.has("params"):
			params = action.params
		Interactions.triggerTargetsWithParams(get_tree(), [action.targets], message, params)
	pass

func on_trigger_entities(_target:String, _message:String, _dict:Dictionary) -> void:
	if _target == "":
		return
	_fire_event(_data, _target)
