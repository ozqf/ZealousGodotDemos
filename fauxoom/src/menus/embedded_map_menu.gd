extends Control

signal menu_navigate(name)

func _ready() -> void:
	var _f = $VBoxContainer/back.connect("pressed", self, "_on_back")
	_f = $VBoxContainer/prologue.connect("pressed", self, "_on_play_prologue")
	_f = $VBoxContainer/catacombs_campaign.connect("pressed", self, "_on_play_catacombs_campaign")
	_f = $VBoxContainer/catacombs_king.connect("pressed", self, "_on_play_catacombs_king")

func _on_play_prologue() -> void:
	_on_back()
	Main.submit_console_command("map prologue_subway")
	pass

func _on_play_catacombs_campaign() -> void:
	_on_back()
	Main.submit_console_command("play catacombs_01")

func _on_play_catacombs_king() -> void:
	_on_back()
	Main.submit_console_command("play catacombs_01_king")

# func _on_test_entities() -> void:
# 	_on_back()
# 	Main.submit_console_command("map test_entities")

func _on_back() -> void:
	self.emit_signal("menu_navigate", "back")

func on() -> void:
	self.visible = true

func off() -> void:
	self.visible = false
