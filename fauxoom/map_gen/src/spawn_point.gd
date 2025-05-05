extends Area3D
class_name SpawnPoint

const _selectedMat:StandardMaterial3D = preload("../materials/spawn_point_selected.tres")
const _unselectedMat:StandardMaterial3D = preload("../materials/spawn_point_unselected.tres")
const _highlightedMat:StandardMaterial3D = preload("../materials/spawn_point_highlighted.tres")
const _mapSpawnDef_t = preload("./map_spawn_def.gd")

@onready var _mesh:MeshInstance3D = $display/MeshInstance3D
# @export var entType:String = ""

var def:MapSpawnDef = _mapSpawnDef_t.new()

var _selected:bool = false
var _highlighted:bool = false

func _refresh_mat() -> void:
	if _selected:
		# print("Set selected")
		_mesh.set_material_override(_selectedMat)
	elif _highlighted:
		# print("Set highlighted")
		_mesh.set_material_override(_highlightedMat)
	else:
		# print("Set unselected")
		_mesh.set_material_override(_unselectedMat)

func set_selected(flag:bool) -> void:
	_selected = flag
	_refresh_mat()

func set_highlighted(flag:bool) -> void:
	_highlighted = flag
	_refresh_mat()
