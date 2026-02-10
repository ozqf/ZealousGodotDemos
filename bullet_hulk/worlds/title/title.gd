extends Node3D

@onready var _start:CustomButton = $Control/VBoxContainer/start
@onready var _exit:CustomButton = $Control/VBoxContainer/exit

func _ready() -> void:
	_start.connect("custom_pressed", _on_button_pressed)
	_exit.connect("custom_pressed", _on_button_pressed)
	Game.add_cursor_claim("title")

func _exit_tree() -> void:
	Game.remove_cursor_claim("title")

func _on_button_pressed(button:CustomButton) -> void:
	match button.name:
		"start":
			Game.start_game()
		"exit":
			Game.exit_game()
