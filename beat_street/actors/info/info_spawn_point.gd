extends Node

@export var uuid:String = ""

func _ready() -> void:
	if uuid == "":
		print("Spawn point has no uuid")
		return
	Game.register_spawn_point(uuid, self)

func _exit_tree() -> void:
	Game.unregister_spawn_point(uuid)
