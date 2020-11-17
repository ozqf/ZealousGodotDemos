extends Node2D
class_name Game

func on_player_start(_player):
	pass

func on_player_finish(_player):
	pass

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		var _result = get_tree().reload_current_scene()
