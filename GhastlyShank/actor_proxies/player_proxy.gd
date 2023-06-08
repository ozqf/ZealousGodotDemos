extends Node3D

var _playerType:PackedScene = preload("res://actors/player/player.tscn")

func _ready():
	call_deferred("_spawn_player")

func _spawn_player() -> void:
	var plyr:Node3D = _playerType.instantiate() as Node3D
	get_parent().add_child(plyr)
	plyr.global_transform = self.global_transform
