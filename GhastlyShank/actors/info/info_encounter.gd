extends Node

@export var uuid:String = ""
@export var spawnPointsCSV:String = ""

var _points:PackedStringArray

func _ready() -> void:
	_points = spawnPointsCSV.split(",")

func _create_spawn_data(mobPrefabType:String, t:Transform3D) -> Dictionary:
	return {
		"meta": {
			"prefab": mobPrefabType,
			"flags": 0,
			"uuid": UUID.v4(),
			"tags": ""
		},
		"xform": ZqfUtils.Transform3D_to_dict(t)
	}

func actor_trigger(msg:String) -> void:
	match msg:
		_:
			print("Encounter saw trigger")
			var t:Transform3D = self.global_transform
			for spawnPointId in _points:
				var point = Game.get_spawn_point(spawnPointId)
				if point != null && point is Node3D:
					t = point.global_transform
				var data:Dictionary = _create_spawn_data("goon_fodder", t)
				Game.restore_actor(data)
