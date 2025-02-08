extends Control

@onready var _noTarget:CheckBox = $VBoxContainer/checkbox_no_target
@onready var _invul:CheckBox = $VBoxContainer/checkbox_invul

func _ready() -> void:
	_noTarget.connect("pressed", _on_no_target_pressed)
	_invul.connect("pressed", _on_invul_pressed)

func _on_no_target_pressed() -> void:
	_refresh_cheats()

func _on_invul_pressed() -> void:
	_refresh_cheats()

func _refresh_cheats() -> void:
	var flags:int = 0
	if (_noTarget.button_pressed):
		flags |= Game.CHEAT_FLAG_NO_TARGET
	if (_invul.button_pressed):
		flags |= Game.CHEAT_FLAG_INVUL
	var grp:String = Game.GROUP_GAME_EVENTS
	var fn:String = Game.FN_GAME_EVENT_CHEATS_FLAGS_REFRESH
	get_tree().call_group(grp, fn, flags)
