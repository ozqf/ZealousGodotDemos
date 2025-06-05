@tool
extends Button

signal custom_pressed(node)

func _ready() -> void:
	self.connect("pressed", _on_pressed)

func _on_pressed() -> void:
	self.emit_signal("custom_pressed", self)
