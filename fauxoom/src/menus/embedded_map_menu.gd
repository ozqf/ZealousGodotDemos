extends Control

signal menu_navigate(name)

func _ready() -> void:
	var _f = $VBoxContainer/back.connect("pressed", self, "_on_back")

func _on_back() -> void:
	self.emit_signal("menu_navigate", "back")

func on() -> void:
	self.visible = true

func off() -> void:
	self.visible = false
