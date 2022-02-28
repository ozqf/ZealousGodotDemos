extends Spatial

func _enter_tree() -> void:
	print("Dynamic root enter tree")
	Game.register_dynamic_root(self)
	pass

func _exit_tree() -> void:
	print("Dynamic root exit tree")
	Game.deregister_dynamic_root(self)
	pass
