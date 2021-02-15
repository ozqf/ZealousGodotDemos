extends Node

onready var _title:Control = $title_text
onready var _customMapMenu:Control = $custom_map_menu
onready var _optionsMenu:Control = $options

func on() -> void:
	_title.visible = true
	_customMapMenu.on()

func off() -> void:
	_title.visible = false
	_customMapMenu.off()