extends Navigation
class_name NavService

func _enter_tree() -> void:
	Game.register_nav_service(self)

func _exit_tree() -> void:
	Game.deregister_nav_service(self)
	# var aStar = AStar.new()
	# aStar.
