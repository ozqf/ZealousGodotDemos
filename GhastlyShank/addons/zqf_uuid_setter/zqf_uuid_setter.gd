@tool
extends EditorPlugin
class_name ZqfUUIDSetter

func _enter_tree():
	# connect to selection
	var selection:EditorSelection = get_editor_interface().get_selection()
	selection.connect("selection_changed", _selection_changed)

func _selection_changed() -> void:
	var selection:EditorSelection = get_editor_interface().get_selection()
	var nodes = selection.get_selected_nodes()
	#print("Setter saw " + str(nodes.size()) + " nodes")
	for node in nodes:
		if !"uuid" in node:
			continue
		if node["uuid"] != "":
			continue
		if get_tree().edited_scene_root == node:
			print("Node is root - skipped")
			continue
		node["uuid"] = UUID.v4()
		print(node.name + " applied uuid " + node["uuid"])
