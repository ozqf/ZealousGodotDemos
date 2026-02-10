extends Control

func _ready() -> void:
	$VBoxContainer/resume.connect("pressed", _resume)
	$VBoxContainer/title.connect("pressed", _title)

func _resume() -> void:
	self.visible = false
	Game.unpause_game()

func _title() -> void:
	self.visible = false
	Game.goto_title()
