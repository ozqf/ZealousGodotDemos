extends Node

var _player_projectile = preload("res://prefabs/player_projectile.tscn")

var cursorPos = Vector2()

func get_current_scene_root():
	return get_tree().get_current_scene()

func get_free_player_projectile():
	var prj = _player_projectile.instance()
	get_current_scene_root().add_child(prj)
	return prj
