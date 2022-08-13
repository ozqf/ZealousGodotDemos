extends Node

var _active:bool = false

func _ready() -> void:
	pass

func on_player_died(_info:Dictionary) -> void:
	if !_active:
		return
	pass

func on_level_completed() -> void:
	if !_active:
		return
	pass
