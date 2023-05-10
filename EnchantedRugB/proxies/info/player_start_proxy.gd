extends Node

var _playerStartType = preload("res://actors/player/player_start.tscn")

func _ready() -> void:
	self.add_to_group(Zqf.GROUP_NAME_ACTOR_PROXIES)

func spawn() -> void:
	Game.add_actor_scene(_playerStartType, self.global_transform)
