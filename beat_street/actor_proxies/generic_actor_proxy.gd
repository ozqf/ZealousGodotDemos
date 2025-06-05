extends ActorProxyBase

enum ActorType
{
	None,
	PlayerStart,
	TargetDummy,
	WallTurret
}

@export var actorType:ActorType = ActorType.None

func _ready():
	self.visible = false
	add_to_group(ZqfActorProxyEditor.GroupName)

func get_spawn_data() -> Dictionary:
	var info = super.get_spawn_data()
	info.meta.prefab = "wall_turret"
	return info
