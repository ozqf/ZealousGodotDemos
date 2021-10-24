extends Node

const DEG2RAD = 0.017453292519
const RAD2DEG = 57.2958

var _player_projectile = preload("res://prefabs/player_projectile.tscn")

var cursorPos = Vector2()

var _player:Actor = null

var cheatNoTarget:bool = true

func register_player(_newPlayer:Actor) -> void:
	_player = _newPlayer
	print("Game registered player")

func remove_player(_newplayer:Actor) -> void:
	_player = null
	print("Game removed player")

func get_player() -> Actor:
	if cheatNoTarget:
		return null
	return _player

func get_current_scene_root():
	return get_tree().get_current_scene()

func get_free_player_projectile():
	var prj = _player_projectile.instance()
	get_current_scene_root().add_child(prj)
	return prj
