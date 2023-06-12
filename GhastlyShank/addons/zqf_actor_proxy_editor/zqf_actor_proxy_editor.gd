@tool
extends EditorPlugin

var _settingsDockType = preload("res://addons/zqf_actor_proxy_editor/proxy_settings_dock.tscn")
var _settingsDock

func _enter_tree():
	print("Init actor proxy settings")
	# create dock
	_settingsDock = _settingsDockType.instantiate()
	add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_UL, _settingsDock)
	_link_to_dock(_settingsDock)
	
	# connect to selection
	var selection:EditorSelection = get_editor_interface().get_selection()
	selection.connect("selection_changed", _selection_changed)

func _exit_tree():
	remove_control_from_docks(_settingsDock)
	_settingsDock.free()
	pass

##########################################################
# Dock controls

var _disabledRoot:Control
var _enabledRoot:Control

func _link_to_dock(dock) -> void:
	_disabledRoot = dock.get_node_or_null("disabled")
	_enabledRoot = dock.get_node_or_null("enabled")

func set_enabled(flag:bool) -> void:
	_enabledRoot.visible = flag
	_disabledRoot.visible = !flag

func _get_proxy():
	var selection:EditorSelection = get_editor_interface().get_selection()
	var nodes = selection.get_selected_nodes()
	if nodes.size() != 1:
		return null
	var node = nodes[0]
	if !node.has_method("get_actor_proxy_info"):
		print("Node is not an actor proxy")
		return null
	return node

func _selection_changed() -> void:
	print("Proxy dock saw selection change")
	var proxy = _get_proxy()
	if proxy == null:
		set_enabled(false)
		return
	print("Got an actor proxy")
	set_enabled(true)
	edit_node(proxy)

##########################################################
# Edit node

func edit_node(node) -> void:
	if node.has_method("get_actor_proxy_info"):
		var info:Dictionary = node.get_actor_proxy_info()
		print("Editing type: " + str(info.meta.prefab))
	pass
