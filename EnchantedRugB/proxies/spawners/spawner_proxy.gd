extends Node

var _spawnerActorType:PackedScene = preload("res://actors/spawners/spawner.tscn")

@export var mobType:GameCtrl.MobType = GameCtrl.MobType.Fallback
@export_flags("1", "2", "3", "4", "5", "6") var spawnLayerFlags:int = 1

func _ready() -> void:
	self.add_to_group(Zqf.GROUP_NAME_ACTOR_PROXIES)
	self.visible = false

func spawn() -> void:
	var spawner = Game.add_actor_scene(_spawnerActorType, self.global_transform)
	spawner.mobType = mobType
	spawner.restart()
