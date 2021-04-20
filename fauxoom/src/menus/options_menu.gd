extends Control
class_name OptionsMenu

signal menu_navigate(name)

onready var _invertedY:CheckBox = $VBoxContainer/inverted_mouse/CheckBox
onready var _sensitivity:LineEdit = $VBoxContainer/mouse_sensitivity/LineEdit

onready var _windowed:CheckBox = $VBoxContainer/windowed/CheckBox
onready var _fovLabel:Label = $VBoxContainer/fov/Label
onready var _fov:HSlider = $VBoxContainer/fov/HSlider

onready var _sfx:HSlider = $VBoxContainer/sound_volume/HSlider
onready var _bgm:HSlider = $VBoxContainer/music_volume/HSlider

func _ready() -> void:
	var _f = $VBoxContainer/back.connect("pressed", self, "_on_back")
	_f = _invertedY.connect("pressed", self, "_inverted_y_pressed")
	_f = _windowed.connect("pressed", self, "_windowed_pressed")
	_f = _fov.connect("value_changed", self, "_fov_changed")
	_f = _sensitivity.connect("text_changed", self, "_sensitivity_changed")
	_f = _sfx.connect("value_changed", self, "_sfx_changed")
	_f = _bgm.connect("value_changed", self, "_bgm_changed")

func on() -> void:
	self.visible = true
	_invertedY.pressed = Main.cfg.controls.invertedY
	_windowed.pressed = !Main.cfg.window.fullScreen
	_sensitivity.text = str(Main.cfg.controls.sensitivity)
	_sfx.value = Main.cfg.sound.sfx
	_bgm.value = Main.cfg.sound.bgm
	_fov.value = Main.cfg.window.fov
	_fovLabel.text = "Field of View (" + str(_fov.value) + ")"

func off() -> void:
	self.visible = false

func _on_back() -> void:
	self.emit_signal("menu_navigate", "back")

func _fov_changed(val:float) -> void:
	Main.cfg.window.fov = val
	_fovLabel.text = "Field of View (" + str(val) + ")"
	Main.broadcast_cfg_change()

func _sfx_changed(val:float) -> void:
	Main.cfg.sound.sfx = val
	Main.broadcast_cfg_change()

func _bgm_changed(val:float) -> void:
	Main.cfg.sound.bgm = val
	Main.broadcast_cfg_change()

func _sensitivity_changed(txt:String) -> void:
	var f:float = float(txt)
	if f == 0:
		f = 10
	Main.cfg.controls.sensitivity = f
	print("Sensitivity " + str(f))
	Main.broadcast_cfg_change()

func _inverted_y_pressed() -> void:
	Main.cfg.controls.invertedY = _invertedY.pressed
	# print("InvertedY: " + str(_invertedY.pressed))
	Main.broadcast_cfg_change()

func _windowed_pressed() -> void:
	Main.cfg.window.fullScreen = !_windowed.pressed
	Main.broadcast_cfg_change()
