extends Node
class_name ZEEUIField

signal field_changed(fieldName, fieldValue)

onready var _label:Label = $Label
onready var _input:LineEdit = $input

export var fieldName:String = ""

func _ready():
	var _r = _input.connect("text_entered", self, "on_field_value_set")
	pass

func init(newFieldName, fieldLabel, defaultValue) -> void:
	fieldName = newFieldName
	_label.text = fieldLabel
	_input.text = str(defaultValue)

func on_field_value_set(_txt) -> void:
	self.emit_signal("field_changed", fieldName, _txt)
