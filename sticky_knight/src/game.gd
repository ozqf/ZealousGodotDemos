extends Node
class_name Game

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().reload_current_scene()
