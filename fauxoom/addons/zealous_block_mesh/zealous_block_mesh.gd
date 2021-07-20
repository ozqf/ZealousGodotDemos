tool
extends EditorPlugin

const _gizmo_t = preload("res://addons/zealous_block_mesh/zealous_block_gizmo.gd")
var _gizmo = _gizmo_t.new()

var _generateButton:Button
var _showGizmoToggleButton:Button
var _node:Node = null

func _enter_tree():
	print("Zealous block init")
	
	# setup buttons
	_generateButton = Button.new()
	_generateButton.text = "Block2Mesh"
	var _foo = _generateButton.connect("pressed", self, "generate")
	add_control_to_container(CONTAINER_SPATIAL_EDITOR_MENU, _generateButton)
	
	_showGizmoToggleButton = Button.new()
	_showGizmoToggleButton.text = "Toggle Gizmos"
	_foo = _showGizmoToggleButton.connect("pressed", self, "onToggleShowGizmo")
	add_control_to_container(CONTAINER_SPATIAL_EDITOR_MENU, _showGizmoToggleButton)
	
	# setup gizmo
	add_spatial_gizmo_plugin(_gizmo)

func onToggleShowGizmo():
	_gizmo.bShow = !_gizmo.bShow

func _exit_tree():
	print("Zealous block shutdown")
	remove_control_from_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, _generateButton)
	remove_control_from_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, _showGizmoToggleButton)
	remove_spatial_gizmo_plugin(_gizmo)

func handles(obj) -> bool:
	if obj is ZGUBlock2Mesh:
		return true
	return false

func make_visible(visible):
	if _generateButton != null:
		_generateButton.visible = visible

func edit(node:Object) -> void:
	_node = node

func _list_parents(root:Node) -> void:
	while root != null:
		print("Node - " + str(root))
		root = root.get_parent()

func generate() -> void:
	print("Block2mesh - generate from " + str(_node))
	var root:Spatial = _node
	_list_parents(root)
