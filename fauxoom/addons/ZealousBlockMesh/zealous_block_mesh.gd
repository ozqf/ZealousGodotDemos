tool
extends EditorPlugin

var _button:Button
var _node:Node = null

func _enter_tree():
	_button = Button.new()
	_button.text = "Block2Mesh"
	var _foo = _button.connect("pressed", self, "generate")
	
	add_control_to_container(CONTAINER_SPATIAL_EDITOR_MENU, _button)
	
	pass

func handles(obj) -> bool:
	if obj is ZGUBlock2Mesh:
		return true
	return false

func make_visible(visible):
	if _button != null:
		_button.visible = visible

func _exit_tree():
	remove_control_from_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, _button)

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
