extends Node

var _spawnerActorType:PackedScene = preload("res://actors/spawners/spawner.tscn")

func _ready() -> void:
	self.add_to_group(Zqf.GROUP_NAME_ACTOR_PROXIES)
	self.visible = false

func spawn() -> void:
	Game.add_actor_scene(_spawnerActorType, self.global_transform)
	
