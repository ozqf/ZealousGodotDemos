extends Control
class_name RootMenu

@onready var _start:Button = $VBoxContainer/start
@onready var _title:Button = $VBoxContainer/title
@onready var _gym:Button = $VBoxContainer/gym
@onready var _backToGame:Button = $VBoxContainer/back_to_game

var _on:bool = false

func _ready() -> void:
	_start.connect("pressed", _on_start)
	_title.connect("pressed", _on_back_to_title)
	_gym.connect("pressed", _on_gym)
	_backToGame.connect("pressed", _on_back_to_game)
	off()

func _on_start() -> void:
	off()
	Game.start_new_game()

func _on_back_to_game() -> void:
	off()

func _on_back_to_title() -> void:
	off()
	Game.start_title()

func _on_gym() -> void:
	off()
	Game.start_gym()

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
