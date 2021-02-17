extends Node

onready var _console:LineEdit = $console
onready var _title:Control = $title_text
onready var _customMapMenu:Control = $custom_map_menu
onready var _optionsMenu:Control = $options

func on() -> void:
	_title.visible = true
	_console.visible = true
	_customMapMenu.on()

func off() -> void:
	_title.visible = false
	_console.visible = false
	_customMapMenu.off()

func _process(_delta:float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		var txt:String = _console.text
		_console.text = ""
		if txt != "":
			get_tree().call_group("console", "console_on_exec", txt)
