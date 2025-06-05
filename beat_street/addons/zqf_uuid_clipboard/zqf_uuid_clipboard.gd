@tool
extends EditorPlugin


func _enter_tree():
	# Initialization of the plugin goes here.
	var copyUUIDsButton = Button.new()
	copyUUIDsButton.connect("pressed", _on_copy_uuids)
	copyUUIDsButton.text = "UUID CSV"
	add_control_to_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, copyUUIDsButton)

	var setUUIDsButton = Button.new()
	setUUIDsButton.connect("pressed", _on_new_uuid)
	setUUIDsButton.text = "New UUID"
	add_control_to_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, setUUIDsButton)

	pass

func _exit_tree():
	# Clean-up of the plugin goes here.
	pass

func _on_copy_uuids() -> void:
	var selection:EditorSelection = get_editor_interface().get_selection()
	var nodes = selection.get_selected_nodes()
	var uuids:PackedStringArray = []
	for node in nodes:
		if !"uuid" in node:
			continue
		if typeof(node.uuid) != TYPE_STRING:
			continue
		uuids.push_back(node.uuid)
	var csv:String = ZqfUtils.join_strings(uuids, ",")
	print("UUIDs: " + csv)
	DisplayServer.clipboard_set(csv)

func _on_new_uuid() -> void:
	var selection:EditorSelection = get_editor_interface().get_selection()
	var nodes = selection.get_selected_nodes()
	print("Resetting uuids on " + str(nodes.size()) + " nodes")
	for node in nodes:
		if !"uuid" in node:
			continue
		if typeof(node.uuid) != TYPE_STRING:
			continue
		node.uuid = UUID.v4()
