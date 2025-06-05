@tool
extends Node3D
class_name ActorProxyBase

@export_flags("sk_0", "sk_1", "sk_2", "sk_3", "sk_4", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20") var spawnGroups:int = 63

@export var uuid:String = ""
@export var prefabName:String = ""
@export var tags:String = ""
@export var flags:int = 0

func _ready() -> void:
	add_to_group(ZqfActorProxyEditor.GroupName)

func get_actor_proxy_info() -> Dictionary:
	return {
		"meta": {
			"prefab": "player_start",
			"uuid": uuid,
			"flags": 0,
			"tags": ""
		}
	}

func get_spawn_data() -> Dictionary:
	return {
		"meta": {
			"prefab": "player_start",
			"uuid": uuid,
			"flags": 0,
			"tags": ""
		},
		"xform": ZqfUtils.Transform3D_to_dict(self.global_transform)
	}
