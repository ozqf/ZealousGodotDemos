extends Control
class_name HudObjectives

const GROUP_NAME:String = "hud_objectives"
const FN_ADD_OBJECTIVE:String = "objectives_add"
const FN_REMOVE_OBJECTIVE:String = "objectives_remove"
const FN_CLEAR_OBJECTIVES:String = "objectives_clear"

onready var _text:Label = $VBoxContainer/Label

var _objectiveStrings = []

func _ready():
	self.add_to_group(GROUP_NAME)
	objectives_clear()
	# just hide for now until properly implemented
	self.visible = false

func _refresh_strings() -> void:
	var output:String = ""
	for text in _objectiveStrings:
		output += text + "\n"
	_text.text = output
	print("Objectives text: " + str(output))
	# self.visible = (output != "")

func objectives_clear() -> void:
	_objectiveStrings = []
	_refresh_strings()

func objectives_add(text:String) -> void:
	if _objectiveStrings.find(text) == -1:
		print("Add objective " + text)
		_objectiveStrings.push_back(text)
		_refresh_strings()

func objectives_remove(text:String) -> void:
	var i:int = _objectiveStrings.find(text)
	if i == -1:
		return
	print("Remove objective " + text)
	_objectiveStrings.remove(i)
	_refresh_strings()
