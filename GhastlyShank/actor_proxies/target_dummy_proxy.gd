@tool
extends Node3D

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
