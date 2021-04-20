extends Control

signal menu_navigate(name)

var _actions = [
	"move_forward",
	"move_backward",
	"move_left",
	"move_right",
	"move_up",
	"move_down",
	"move_special",
	"attack_1",
	"slot_1",
	"slot_2",
	"slot_3",
	"slot_4",
	"slot_5",
	"slot_6",
	"slot_7",
	"slot_8"
]

var _active:bool = false

func _ready():
	var _r = $VBoxContainer/back.connect("pressed", self, "_on_back")

func on() -> void:
	_active = true
	self.visible = true
	# _invertedY.pressed = Config.cfg.i_invertedY
	# _windowed.pressed = !Config.cfg.r_fullscreen

func off() -> void:
	_active = false
	self.visible = false

func _on_back() -> void:
	self.emit_signal("menu_navigate", "back")
	self.visible = false

func _input(_event: InputEvent):
	if !_active:
		return
	if _event is InputEventKey:
		print("Key event " + str(_event))
	if _event is InputEventMouseButton:
		print("mouse button event " + str(_event))

######################
# binds
######################
