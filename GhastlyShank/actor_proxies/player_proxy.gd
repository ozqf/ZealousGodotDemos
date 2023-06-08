extends Node3D

var _playerType:PackedScene = preload("res://actors/player/player.tscn")

func _ready():
	self.visible = false
	call_deferred("_spawn_player")

func _spawn_player() -> void:
	var plyr:Node3D = _playerType.instantiate() as Node3D
	Zqf.get_actor_root().add_child(plyr)
	plyr.global_transform = self.global_transform
