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
	_invertedY.pressed = Config.cfg.i_invertedY
	_windowed.pressed = !Config.cfg.r_fullscreen
	_sensitivity.text = str(Config.cfg.i_sensitivity)
	_sfx.value = Config.cfg.s_sfx
	_bgm.value = Config.cfg.s_bgm
	_fov.value = Config.cfg.r_fov
	_fovLabel.text = "Field of View (" + str(_fov.value) + ")"

func off() -> void:
	self.visible = false

func _on_back() -> void:
	self.emit_signal("menu_navigate", "back")

func _fov_changed(val:float) -> void:
	Config.cfg.r_fov = val
	_fovLabel.text = "Field of View (" + str(val) + ")"
	Config.broadcast_cfg_change()

func _sfx_changed(val:float) -> void:
	Config.cfg.s_sfx = val
	Config.broadcast_cfg_change()

func _bgm_changed(val:float) -> void:
	Config.cfg.s_bgm = val
	Config.broadcast_cfg_change()

func _sensitivity_changed(txt:String) -> void:
	var f:float = float(txt)
	if f == 0:
		f = 10
	Config.cfg.i_sensitivity = f
	print("Sensitivity " + str(f))
	Config.broadcast_cfg_change()

func _inverted_y_pressed() -> void:
	Config.cfg.i_invertedY = _invertedY.pressed
	# print("InvertedY: " + str(_invertedY.pressed))
	Config.broadcast_cfg_change()

func _windowed_pressed() -> void:
	Config.cfg.r_fullscreen = !_windowed.pressed
	Config.broadcast_cfg_change()
