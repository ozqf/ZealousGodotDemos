extends Button
class_name CustomButton

signal custom_pressed(button)

var data:String = ""

func _ready() -> void:
	self.connect("pressed", _pressed)

func _pressed() -> void:
	custom_pressed.emit(self)
