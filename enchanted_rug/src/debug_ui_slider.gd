extends Node

onready var _label:Label = $Label
onready var _slider:Slider = $HSlider

# var _originalLabel:String = ""
# var _settings:Dictionary = {}
var _setting:Dictionary = {
	"value": 50.0,
	"default": 50.0,
	"editMin": 1,
	"editMax": 100,
	"step": 0.1
}

var _varName:String = ""

var _editable:bool = true

func _ready() -> void:
	var _foo = _slider.connect("value_changed", self, "on_changed")
	# _originalLabel = _label.text

func init(sourceDict:Dictionary, varName:String) -> void:
	_setting = sourceDict[varName]

	_varName = varName
	reset()

func set_editable(flag:bool) -> void:
	_editable = flag
	_slider.visible = _editable

func reset() -> void:
	# var setting:Dictionary = _settings[_varName]
	_slider.min_value = _setting.editMin
	_slider.max_value = _setting.editMax
	_slider.value = _setting.default
	refresh_display()

func on_changed(value:float) -> void:
	# var setting:Dictionary = _settings[_varName]
	_setting.value = value
	refresh_display()

func refresh_display() -> void:
	_label.text = _varName + ": " + str(_slider.value)
