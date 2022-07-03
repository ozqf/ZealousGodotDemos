extends Control

signal menu_navigate(name)

onready var _root:Control = $VBoxContainer
onready var _popUp:Control = $rebinding_popup
onready var _popUpLabel:Label = $rebinding_popup/Label

var _actions = [
	{ tag = "move_forward", label = "Move Forward" },
	{ tag = "move_backward", label = "Move Backward" },
	{ tag = "move_left", label = "Move Left" },
	{ tag = "move_right", label = "Move Right" },
	{ tag = "move_up", label = "Move Up" },
	{ tag = "move_down", label = "Move Down" },
	{ tag = "move_special", label = "Move Special" },
	{ tag = "attack_1", label = "Attack Primary" },
	{ tag = "attack_1", label = "Attack Secondary" },
	{ tag = "attack_offhand", label = "Offhand Grenade" },
	{ tag = "interact", label = "Interact/Use" },
	{ tag = "hyper", label = "Rage Toggle" },
	{ tag = "slot_1", label = "Select slot 1" },
	{ tag = "slot_2", label = "Select slot 2" },
	{ tag = "slot_3", label = "Select slot 3" },
	{ tag = "slot_4", label = "Select slot 4" },
	{ tag = "slot_5", label = "Select slot 5" },
	{ tag = "slot_6", label = "Select slot 6" },
	{ tag = "slot_7", label = "Select slot 7" },
	{ tag = "slot_8", label = "Select slot 8" }
]

var _loaded:bool = false
var _active:bool = false
var _isRebinding:String = ""

export var verbose:bool = false

func _ready():
	add_to_group(Config.GROUP)
	off()

func config_changed(_cfg:Dictionary) -> void:
	if _loaded:
		return
	_loaded = true
	_build()

func _build():
	var _r = $VBoxContainer/back.connect("pressed", self, "_on_back")
	for action in _actions:
		var container:HBoxContainer = HBoxContainer.new()
		container.alignment = BoxContainer.ALIGN_CENTER
		var label:Label = Label.new()
		var b:Button = Button.new()

		label.text = action.label
		b.text = action.tag
		var map = InputMap.get_action_list(action.tag)[0]
		if map is InputEventKey:
			b.text = str(map.scancode)
		else:
			b.text = "None-key"
			b.disabled = true

		b.connect("pressed", self, "_begin_rebind", [action.tag])

		# keep a reference to this button so we can update its text
		action.button = b

		container.add_child(label)
		container.add_child(b)
		_root.add_child(container)
	load_scancodes_from_config()

func load_scancodes_from_config() -> void:
	if verbose:
		print("Loading input binds")
	for action in _actions:
		if !Config.cfg.has(action.tag):
			continue
		var cfgCode = Config.cfg[action.tag]
		# print("Rebinding " + str(action.tag) + " to " + str(cfgCode))
		# defaults in config will be 0 - keep godot value
		if cfgCode == 0:
			continue
		var event = InputEventKey.new()
		event.scancode = cfgCode
		_rebind(action.tag, event, false)

func write_to_config() -> void:
	for action in _actions:
		if action.has("scancode"):
			Config.cfg[action.tag] = action.scancode
	Config.broadcast_cfg_change()

func _begin_rebind(tag:String) -> void:
	if verbose:
		print("Begin rebind of action " +tag)
	_isRebinding = tag
	Main.isRebinding = true
	_popUp.visible = true
	_popUpLabel.text = "Press new key for " + tag + "\nEscape to cancel"

func _find_action(tag:String) -> Dictionary:
	for action in _actions:
		if action.tag == tag:
			return action
	return {}

func _stop_rebind() -> void:
	_isRebinding = ""
	Main.isRebinding = false
	_popUp.visible = false

func on() -> void:
	_active = true
	self.visible = true
	# _invertedY.pressed = Config.cfg.i_invertedY
	# _windowed.pressed = !Config.cfg.r_fullscreen

func off() -> void:
	_stop_rebind()
	_active = false
	self.visible = false

func _on_back() -> void:
	self.emit_signal("menu_navigate", "back")
	_isRebinding = ""
	self.visible = false

func _input(_event: InputEvent):
	if !_active:
		return
	if _isRebinding == "":
		return
	if _event is InputEventKey:
		if verbose:
			print("Key event " + str(_event))
		if _event.scancode == KEY_ESCAPE:
			_stop_rebind()
			return
		_rebind(_isRebinding, _event, true)
		_isRebinding = ""
	if _event is InputEventMouseButton:
		if verbose:
			print("mouse button event " + str(_event))

######################
# binds
######################

func _rebind(tag:String, keyCode, writeConfig:bool) -> void:
	if verbose:
		print("Rebind " + tag + " to keycode " + str(keyCode))
	# remove current binding to this action - only removes first atm
	if !InputMap.get_action_list(tag).empty():
		InputMap.action_erase_event(tag, InputMap.get_action_list(tag)[0])
	
	# erase other references to this key code
	for i in _actions:
		if InputMap.action_has_event(i.tag, keyCode):
			InputMap.action_erase_event(i.tag, keyCode)
	
	# add new key
	InputMap.action_add_event(tag, keyCode)
	var action = _find_action(tag)
	action.scancode = keyCode.scancode
	# action.button.text = str(keyCode.scancode)
	action.button.text = OS.get_scancode_string(keyCode.scancode)
	if writeConfig:
		write_to_config()
	_stop_rebind()
	
