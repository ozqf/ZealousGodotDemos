extends Node

signal menu_navigate(name)

onready var _console:LineEdit = $console
onready var _bg:ColorRect = $background
# onready var _title:Control = $title_text
onready var _rootMenu:Control = $root_menu
onready var _embeddedMapMenu:Control = $embedded_maps
onready var _customMapMenu:Control = $custom_map_menu
onready var _optionsMenu:Control = $options
onready var _bindsMenu:Control = $binds

enum MenuPage {
	Root,
	EmbeddedMaps,
	CustomMaps,
	Options,
	Binds
}

var _menu = MenuPage.Root

func _ready() -> void:
	var _f
	_f = $root_menu/VBoxContainer/embedded_maps.connect("pressed", self, "_on_goto_embedded")
	_f = $root_menu/VBoxContainer/resume.connect("pressed", self, "_on_back_to_game")
	_f = $root_menu/VBoxContainer/custom_maps.connect("pressed", self, "_on_goto_custom")
	_f = $root_menu/VBoxContainer/restart.connect("pressed", self, "_on_restart")
	_f = $root_menu/VBoxContainer/load_checkpoint.connect("pressed", self, "_on_load_checkpoint")
	_f = $root_menu/VBoxContainer/options.connect("pressed", self, "_on_goto_options")
	_f = $root_menu/VBoxContainer/binds.connect("pressed", self, "_on_goto_binds")
	_f = $root_menu/VBoxContainer/quit.connect("pressed", self, "_on_root_quit")
	
	_f = _embeddedMapMenu.connect("menu_navigate", self, "_on_navigate_callback")
	_f = _customMapMenu.connect("menu_navigate", self, "_on_navigate_callback")
	_f = _optionsMenu.connect("menu_navigate", self, "_on_navigate_callback")
	_f = _bindsMenu.connect("menu_navigate", self, "_on_navigate_callback")

	_optionsMenu.visible = false
	_embeddedMapMenu.visible = false

func _on_goto_embedded() -> void:
	_change_menu(MenuPage.EmbeddedMaps)

func _on_back_to_game() -> void:
	Main.set_input_on()

func _on_goto_custom() -> void:
	_change_menu(MenuPage.CustomMaps)

func _on_goto_options() -> void:
	_change_menu(MenuPage.Options)

func _on_goto_binds() -> void:
	_change_menu(MenuPage.Binds)

func _on_restart() -> void:
	Main.set_input_on()
	get_tree().call_group("console", "console_on_exec", "load start", ["load", "start"])

func _on_load_checkpoint() -> void:
	Main.set_input_on()
	get_tree().call_group("console", "console_on_exec", "load start", ["load", "checkpoint"])

func _on_root_quit() -> void:
	get_tree().call_group("console", "console_on_exec", "exit", ["exit"])
	# get_tree().quit()

func _root_on() -> void:
	_rootMenu.visible = true

func _root_off() -> void:
	_rootMenu.visible = false

func _on_navigate_callback(nameOfTarget:String) -> void:
	if nameOfTarget == "back":
		_change_menu(MenuPage.Root)

func _change_menu(newMenuEnum) -> void:
	off()
	_menu = newMenuEnum
	on()

func on() -> void:
	_bg.visible = true
	
	_console.visible = false
	if _menu == MenuPage.Root:
		_console.visible = true
		_console.grab_focus()
		_rootMenu.visible = true
	elif _menu == MenuPage.EmbeddedMaps:
		_embeddedMapMenu.on()
	elif _menu == MenuPage.CustomMaps:
		_customMapMenu.on()
	elif _menu == MenuPage.Options:
		_optionsMenu.on()
	elif _menu == MenuPage.Binds:
		_bindsMenu.on()
	else:
		print("Unknown menu mode")
		_change_menu(MenuPage.Root)
		return

func off() -> void:
	_bg.visible = false
	_console.visible = false
	
	if _menu == MenuPage.Root:
		_rootMenu.visible = false
	elif _menu == MenuPage.EmbeddedMaps:
		_embeddedMapMenu.off()
	elif _menu == MenuPage.CustomMaps:
		_customMapMenu.off()
	elif _menu == MenuPage.Options:
		_optionsMenu.off()
	else:
		print("Unknown menu mode")
		return

func _process(_delta:float) -> void:
	if Input.is_action_just_pressed("ui_accept") && _console.has_focus():
		var txt:String = _console.text
		_console.text = ""
		if txt != "":
			print("EXEC " + txt)
			var tokens = ZqfUtils.tokenise(txt)
			get_tree().call_group("console", "console_on_exec", txt, tokens)
