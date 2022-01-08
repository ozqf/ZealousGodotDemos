extends Navigation
class_name NavService

onready var _navMesh:NavigationMeshInstance = $NavigationMeshInstance

func _enter_tree() -> void:
	AI.register_nav_service(self)

func _exit_tree() -> void:
	AI.deregister_nav_service(self)
	# var aStar = AStar.new()
	# aStar.
