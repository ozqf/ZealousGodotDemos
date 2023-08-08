@tool
extends ActorProxyBase

@export var ent_flags:int = 0
@export var ent_tags:String = ""
@export var ent_deathTags:String = ""

func _ready() -> void:
	add_to_group(ZqfActorProxyEditor.GroupName)

func get_actor_proxy_info() -> Dictionary:
	return {
		"meta": {
			"prefab": "target_dummy",
			"flags": 0,
			"tags": ""
		}
	}

func get_spawn_data() -> Dictionary:
	return {
		"meta": {
			"prefab": "target_dummy",
			"flags": 0,
			"tags": ""
		},
		"xform": ZqfUtils.Transform3D_to_dict(self.global_transform)
	}
