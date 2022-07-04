extends Node
class_name ZEEUIFieldSpecial

signal edit_special_field(fieldName)

onready var _label:Label = $Label
onready var _button:Button = $input

export var fieldName:String = ""

func _ready():
	var _r = _button.connect("pressed", self, "_on_pressed")
	pass

func init(newFieldName, fieldLabel, defaultValue) -> void:
	fieldName = newFieldName
	_label.text = fieldLabel

func _on_pressed() -> void:
	# print(fieldName + " pressed")
	self.emit_signal("edit_special_field", fieldName)
	pass
