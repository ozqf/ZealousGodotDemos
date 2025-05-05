extends Navigation
class_name NavService
# TODO - Plan here is to create a 'higher level' navigation system
# from waypoints. Routes are planned between nodes, with actuall movement
# handled by the godot navigation mesh.
@onready var _navMesh:NavigationMeshInstance = $NavigationMeshInstance

func _enter_tree() -> void:
	AI.register_nav_service(self)

func _exit_tree() -> void:
	AI.deregister_nav_service(self)
