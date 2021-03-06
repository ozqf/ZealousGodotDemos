extends Node

var _slider_t = preload("res://prefabs/debug_ui_slider.tscn")
onready var _settingsNode:Control = $settings
onready var _console:LineEdit = $console

var _player = null

var _uiNodes = [
]

var _setting_keys = []

var _editable:bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_player = get_parent()
	var _foo = $settings/reset.connect("pressed", self, "reset_to_defaults")

	var settings = settings()
	_setting_keys = settings.keys()
	for _i in range(0, _setting_keys.size()):
		var slider = _slider_t.instance()
		var name = _setting_keys[_i]
		_settingsNode.add_child(slider)
		slider.init(settings, name)
		_uiNodes.push_back(slider)
	set_editable(_editable)

func _process(_delta:float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		var txt = _console.text
		_console.text = ""
		Console.execute(txt)

func set_editable(flag:bool) -> void:
	_editable = flag
	_console.visible = _editable
	if _editable:
		_console.grab_focus()
	$settings/reset.visible = _editable
	for _i in range (0, _uiNodes.size()):
		_uiNodes[_i].set_editable(_editable)
	
func settings() -> Dictionary:
	return _player.get_settings()

func runtime() -> Dictionary:
	return _player.get_runtime()

func reset_to_defaults() -> void:
	for _i in range(0, _uiNodes.size()):
		_uiNodes[_i].reset()
