extends Node3D

var _playerType = preload("res://actors/player/player.tscn")
var _playerBallType = preload("res://actors/player/roller/player_ball.tscn")

func _ready():
	self.visible = false
	call_deferred("_spawn_player")

func _spawn_player() -> void:
	#var plyr = _playerType.instantiate()
	var plyr = _playerBallType.instantiate()
	Zqf.get_actor_root().add_child(plyr)
	plyr.teleport(self.global_transform)
