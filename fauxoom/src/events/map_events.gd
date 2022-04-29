extends Node

export var eventsDict:Dictionary

var _data = {}

func _ready():
	add_to_group(Groups.CONSOLE_GROUP_NAME)
	add_to_group(Groups.ENTS_GROUP_NAME)
	# var mapName = get_tree().current_scene.filename
	var eventsPath:String = "res://maps/catacombs_01/events.tres"
	if !ResourceLoader.exists(eventsPath):
		print("No events file at " + str(eventsPath))
		return
	var data = ZqfUtils.load_dict_json_file(eventsPath)
	_data = data
	print("Read " + str(_data.events.size()) + " events")

func _fire_event(data, eventName:String) -> void:
	for i in range(0, data.events.size()):
		var ev = data.events[i]
		if ev.name != eventName:
			continue
		print("Firing event index " + str(i) + ": " + ev.name)
		for j in range(0, ev.actions.size()):
			var action = ev.actions[j]
			var message:String = ""
			if action.has("message"):
				message = str(action.message)
			var params:Dictionary = ZqfUtils.EMPTY_DICT
			if action.has("params"):
				params = action.params
			Interactions.triggerTargetsWithParams(get_tree(), [action.target], message, params)
	pass

func console_on_exec(_txt:String, _tokens:PoolStringArray) -> void:
	if _tokens[0] != "events":
		return
	if _tokens.size() == 1:
		print("Events - missing param")
		return
	if _tokens[1] == "list":
		var numEvents:int = _data.events.size()
		for _i in range(0, numEvents):
			var ev = _data.events[_i]
			print("Event " + str(_i) + ": " + str(ev.name) + " - has " + str(ev.actions.size()) + " actions")
		return
	if _tokens[1] == "trigger" && _tokens.size() == 3:
		var eventName:String = _tokens[2]
		_fire_event(_data, eventName)
	pass

func on_trigger_entities(_target:String, _message:String, _dict:Dictionary) -> void:
	if _target == "":
		return
	_fire_event(_data, _target)
