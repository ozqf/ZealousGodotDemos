extends Control

func _ready():
	$restart.connect("custom_pressed", _button_pressed)

func _button_pressed(button) -> void:
	match button.name:
		"restart":
			Game.restart()
