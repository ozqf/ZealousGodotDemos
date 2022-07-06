extends Control

onready var _message:LineEdit = $message_edit
onready var _targets:Control = $targets
onready var _presetMessages:OptionButton = $message_presets

var _presets = [
	"",
	"on",
	"off",
	"kill_all_mobs"
]

func _ready() -> void:
	for i in range(0, _presets.size()):
		_presetMessages.add_item(_presets[i], i)
	_presetMessages.connect("item_selected", self, "_on_preset_selected")

func _on_preset_selected(index:int) -> void:
	print("Selected message preset '" + str(_presets[index]) + "'")
	_message.text = _presets[index]
	pass

func read(_dict:Dictionary) -> void:
	
	pass

func write() -> Dictionary:
	return {

	}
