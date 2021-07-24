extends EditorSpatialGizmoPlugin

const gizmo_t = preload("res://addons/zealous_block_mesh/zealous_block_gizmo.gd")

var bShow:bool = true

var _drawCentre:bool = true
var _drawBounds:bool = true

var _specialValue = 1

func get_name() -> String:
	return "Zealous Grid"

func _init() -> void:
	create_material("purple", Color(1, 0, 1), false, true)
	create_material("cyan", Color(0, 1, 1), false, true)
	create_handle_material("handles")

func create_gizmo(spatial):
	if !(spatial is ZealousBlock):
		return null
	return gizmo_t.new()

func has_gizmo(spatial) -> bool:
#	var result = spatial is MeshInstance
	var result = spatial is PhysicsBody
#	print("Has custom gizmo " + str(result))
	return result

# You should implement the rest of handle-related callbacks
# (get_handle_name(), get_handle_value(), commit_handle()...).
