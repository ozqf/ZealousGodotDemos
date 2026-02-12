extends Control

@onready var _retry:Button = $VBoxContainer/retry
@onready var _title:Button = $VBoxContainer/title

func _ready() -> void:
	self.hide_menu()
	_retry.connect("pressed", _on_retry)
	_title.connect("pressed", _on_title)

func show_menu() -> void:
	self.visible = true
	Game.add_cursor_claim("dead_menu")

func hide_menu() -> void:
	self.visible = false
	Game.remove_cursor_claim("dead_menu")

func _on_retry() -> void:
	hide_menu()
	Game.restart()

func _on_title() -> void:
	hide_menu()
	Game.goto_title()
