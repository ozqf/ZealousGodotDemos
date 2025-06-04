extends Node

var _playerStartType = preload("res://actors/player/player_start.tscn")

@export_flags("1", "2", "3", "4", "5", "6") var spawnLayerFlags:int = 1

func _ready() -> void:
	self.add_to_group(Zqf.GROUP_NAME_ACTOR_PROXIES)

func spawn() -> void:
	Game.add_actor_scene(_playerStartType, self.global_transform)
