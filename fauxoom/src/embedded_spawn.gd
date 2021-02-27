# Intentional use of this class and prefab is for maps created
# within godot itself, and not the custom map editor
extends Spatial
class_name EmbeddedSpawn

enum EntityType {
	None = 0,
	MobGrunt = 1,
	Start = 2,
	End = 3,
	Key = 4,
	Trigger = 5,
	Relay = 6,
	Counter = 7,
	Gate = 8,
	HordeSpawn = 9
}
export(EntityType) var type = EntityType.None
export(String) var targetName:String = ""
export(String) var target:String = ""

func get_def() -> MapSpawnDef:
	$actor_spawn.hide()
	var spawn:SpawnPoint = $actor_spawn
	spawn.def.type = type
	var t:Transform = global_transform
	spawn.def.position = t.origin
	spawn.def.yaw = int(rotation_degrees.y)
	spawn.def.triggerName = targetName
	spawn.def.triggerTargetName = target
	return spawn.def
