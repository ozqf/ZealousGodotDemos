extends Node3D

var _playerType = preload("res://actors/player/player.tscn")

func _ready():
	call_deferred("_spawn_player")

func _spawn_player() -> void:
	var plyr = _playerType.instantiate()
	Zqf.get_actor_root().add_child(plyr)
	plyr.teleport(self.global_transform)
