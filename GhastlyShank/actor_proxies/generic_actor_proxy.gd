extends ActorProxyBase

enum ActorType
{
	None,
	PlayerStart,
	TargetDummy
}

@export var actorType:ActorType = ActorType.None

#var _playerType:PackedScene = preload("res://actors/player/player_avatar.tscn")
var _targetDummyType:PackedScene = preload("res://actors/target_dummy/target_dummy.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	self.visible = false
	call_deferred("_spawn")

func _spawn() -> void:
	var scene:PackedScene = null
	match actorType:
		ActorType.TargetDummy:
			scene = _targetDummyType
	if scene == null:
		print("Failed to find actor type " + str(actorType))
		return
	var obj:Node3D = scene.instantiate() as Node3D
	Zqf.get_actor_root().add_child(obj)
	obj.global_transform = self.global_transform
	pass

func get_spawn_data() -> Dictionary:
	var info = super.get_spawn_data()
	info.meta.prefab = "target_dummy"
	return info
