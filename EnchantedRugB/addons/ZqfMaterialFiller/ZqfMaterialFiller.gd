@tool
extends EditorPlugin

var _buttonType = preload("res://addons/ZqfMaterialFiller/button.tscn")

var _button:Button

func _enter_tree():
	# Initialization of the plugin goes here.
	var selection:EditorSelection = get_editor_interface().get_selection()
	selection.connect("selection_changed", _selection_changed)
	
	_button = _buttonType.instantiate()
	add_control_to_container(CustomControlContainer.CONTAINER_SPATIAL_EDITOR_MENU, _button)
	_button.visible = false
	_button.connect("pressed", _on_clicked)
	pass


func _exit_tree():
	# Clean-up of the plugin goes here.
	pass

func _get_selected_mesh() -> MeshInstance3D:
	var selection:EditorSelection = get_editor_interface().get_selection()
	var nodes = selection.get_selected_nodes()
	if nodes.size() != 1:
		return null
	var mesh:MeshInstance3D = nodes[0] as MeshInstance3D
	if mesh == null:
		_button.visible = false
		return null
	return mesh

func _selection_changed() -> void:
	var mesh:MeshInstance3D = _get_selected_mesh()
	if mesh == null:
		_button.visible = false
		return
	print("Selected a mesh!")
	_button.visible = true
	pass

func _get_obj_materials(path:String) -> void:
	pass

func _on_clicked() -> void:
	print("Fill materials")
	var meshInstance:MeshInstance3D = _get_selected_mesh()
	if meshInstance == null:
		print("No selected mesh was found")
		return
	
	var mesh:Mesh = meshInstance.mesh
	if mesh == null:
		print("No mesh found")
	var path:String = mesh.resource_path
	if !path.ends_with(".obj"):
		print("Only .obj mesh resources are supported")
		return
	var numSlots:int = mesh.get_surface_override_material_count()
	print("Found mesh from " + str(path) + " with " + str(numSlots) + " material slots")
	
