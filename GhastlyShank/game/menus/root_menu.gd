extends Control
class_name RootMenu

@onready var _start:Button = $VBoxContainer/start
@onready var _backToGame:Button = $VBoxContainer/back_to_game

var _on:bool = false

func _ready() -> void:
	_start.connect("pressed", _on_start)
	_backToGame.connect("pressed", _on_back_to_game)
	off()

func _on_start() -> void:
	pass

func _on_back_to_game() -> void:
	off()

func is_on() -> bool:
	return _on

func on() -> void:
	_on = true
	self.visible = true
	Zqf.add_mouse_claim(self)
	Zqf.add_pause_claim(self)

func off() -> void:
	_on = false
	self.visible = false
	Zqf.remove_mouse_claim(self)
	Zqf.remove_pause_claim(self)
