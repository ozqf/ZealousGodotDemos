@tool
extends Node3D
class_name ActorProxyBase

@export var prefabName:String = ""
@export var tags:String = ""
@export var flags:int = 0

func _ready() -> void:
	add_to_group(ZqfActorProxyEditor.GroupName)

func get_actor_proxy_info() -> Dictionary:
	return {
		"meta": {
			"prefab": "player_start",
			"flags": 0,
			"tags": ""
		}
	}

func get_spawn_data() -> Dictionary:
	return {
		"meta": {
			"prefab": "player_start",
			"flags": 0,
			"tags": ""
		},
		"xform": ZqfUtils.Transform3D_to_dict(self.global_transform)
	}
