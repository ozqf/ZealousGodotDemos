extends Button
class_name CustomButton

signal custom_pressed(button)

var data = null

func _ready():
	self.connect("pressed", _on_pressed)

func _on_pressed() -> void:
	self.emit_signal("custom_pressed", self)
