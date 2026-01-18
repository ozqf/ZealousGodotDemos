extends Button
class_name CustomButton

static func Create() -> CustomButton:
	var button:CustomButton = CustomButton.new()
	return button

signal custom_pressed(this)
@export var tag:String = ""
@export var data:String = ""

func _ready() -> void:
	self.connect("pressed", _on_pressed)

func _on_pressed() -> void:
	custom_pressed.emit(self)
