extends Node

onready var _label:Label = $Label
onready var _slider:Slider = $HSlider

var _originalLabel:String = ""
var _settings:Dictionary = {}
var _varName:String = ""

func _ready() -> void:
	_slider.connect("value_changed", self, "on_changed")
	_originalLabel = _label.text

func init(sourceDict:Dictionary, varName:String) -> void:
	_settings = sourceDict
	_varName = varName
	reset()

func reset() -> void:
	var setting:Dictionary = _settings[_varName]
	_slider.min_value = setting.editMin
	_slider.max_value = setting.editMax
	_slider.value = setting.default
	refresh_display()

func on_changed(value:float) -> void:
	var setting:Dictionary = _settings[_varName]
	setting.value = value
	refresh_display()

func refresh_display() -> void:
	_label.text = _originalLabel + ": " + str(_slider.value)
