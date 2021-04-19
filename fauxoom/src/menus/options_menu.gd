extends Control
class_name OptionsMenu

signal menu_navigate(name)

onready var _invertedY:CheckBox = $VBoxContainer/inverted_mouse/CheckBox
onready var _windowed:CheckBox = $VBoxContainer/windowed/CheckBox

func _ready() -> void:
	var _f = $VBoxContainer/back.connect("pressed", self, "_on_back")
	_f = _invertedY.connect("pressed", self, "_inverted_y_pressed")
	_f = _windowed.connect("pressed", self, "_windowed_pressed")

func on() -> void:
	self.visible = true
	_invertedY.pressed = Main.cfg.controls.invertedY
	_windowed.pressed = !Main.cfg.window.fullScreen

func off() -> void:
	self.visible = false

func _on_back() -> void:
	self.emit_signal("menu_navigate", "back")

func _inverted_y_pressed() -> void:
	Main.cfg.controls.invertedY = _invertedY.pressed
	# print("InvertedY: " + str(_invertedY.pressed))
	Main.broadcast_cfg_change()

func _windowed_pressed() -> void:
	Main.cfg.window.fullScreen = !_windowed.pressed
	Main.broadcast_cfg_change()
