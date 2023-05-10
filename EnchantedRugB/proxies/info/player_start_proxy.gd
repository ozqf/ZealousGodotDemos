extends Node

var _playerStartType = preload("res://actors/player/player_start.tscn")

func _ready() -> void:
	self.add_to_group(Zqf.GROUP_NAME_ACTOR_PROXIES)

func spawn() -> void:
	var obj = _playerStartType.instantiate()
	Zqf.get_actor_root().add_child(obj)#
	if obj.has_method("teleport"):
		obj.teleport(self.global_transform)
	else:
		obj.global_transform = self.global_transform
