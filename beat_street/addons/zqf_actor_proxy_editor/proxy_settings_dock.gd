extends Control

@onready var _disabledRoot:Control = $disabled
@onready var _enabledRoot:Control = $enabled

func set_enabled(flag:bool) -> void:
	_enabledRoot.visible = flag
	_disabledRoot.visible = !flag
