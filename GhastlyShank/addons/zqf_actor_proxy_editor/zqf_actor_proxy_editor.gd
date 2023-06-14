@tool
extends EditorPlugin
class_name ZqfActorProxyEditor

const GroupName:String = "actor_proxies"

##########################################################
# static
##########################################################

static func _find_actor_proxies(root:Node, results:Array) -> void:
	if !ZqfUtils.is_obj_safe(root):
		return
	if root.has_method("get_actor_proxy_info"):
		results.push_back(root)
	for node in root.get_children():
		_find_actor_proxies(node, results)

static func _find_all_tags(root:Node) -> PackedStringArray:
	var tags:Dictionary = {}
	var proxies:Array = []
	_find_actor_proxies(root, proxies)
	for proxy in proxies:
		for child in proxy.get_children():
			if child is TagsField:
				var csv:String = child.csv
				var childTags = csv.split(",")
				for tag in childTags:
					if tag != "":
						tags[tag] = tag
	return tags.keys()

static func find_trigger_target_positions(originNode) -> Array:
	return originNode.get_tree().get_nodes_in_group(GroupName)
#	return [ Vector3(0, 2, 0) ]

##########################################################
# Instance
##########################################################

var _buttonType = preload("res://addons/zqf_actor_proxy_editor/custom_button.tscn")
var _settingsDockType = preload("res://addons/zqf_actor_proxy_editor/proxy_settings_dock.tscn")
var _triggerLineGizmoType = preload("res://addons/zqf_actor_proxy_editor/gizmos/trigger_line_gizmo_plugin.gd")

var _triggerLineGizmo
var _settingsDock
var _dockFieldsRoot:VBoxContainer

var _tagsNode:TagsField = null

func _enter_tree():
	print("Init actor proxy settings")
	# create dock
	_settingsDock = _settingsDockType.instantiate()
	add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_UL, _settingsDock)
	_link_to_dock(_settingsDock)
	
	# connect to selection
	var selection:EditorSelection = get_editor_interface().get_selection()
	selection.connect("selection_changed", _selection_changed)
	
	_triggerLineGizmo = _triggerLineGizmoType.new()
	add_node_3d_gizmo_plugin(_triggerLineGizmo)

func _exit_tree():
	remove_control_from_docks(_settingsDock)
	_settingsDock.free()
	
	remove_node_3d_gizmo_plugin(_triggerLineGizmo)

##########################################################
# Dock controls
##########################################################

var _disabledRoot:Control
var _enabledRoot:Control

func _link_to_dock(dock) -> void:
	_disabledRoot = dock.get_node_or_null("disabled")
	_enabledRoot = dock.get_node_or_null("enabled")
	_dockFieldsRoot = dock.get_node_or_null("fields")

func set_enabled(flag:bool) -> void:
	_enabledRoot.visible = flag
	_disabledRoot.visible = !flag
	if !flag:
		_remove_fields()

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
	# reset fields
	_remove_fields()
	edit_node(proxy)

##########################################################
# Edit node
##########################################################

# https://docs.godotengine.org/en/latest/classes/class_object.html#id2
# https://docs.godotengine.org/en/latest/classes/class_%40globalscope.html#class-globalscope-constant-type-object
const PROP_TYPE_STRING:int = 4

func _remove_fields() -> void:
	for child in _dockFieldsRoot.get_children():
		child.free()

func _on_edit_field(fieldNode) -> void:
	print("clicked edit field: " + fieldNode.name)
	var tags:PackedStringArray = _find_all_tags(get_editor_interface().get_edited_scene_root())
	print("Found " + str(tags.size()) + " tags")
	var txt:String = ZqfUtils.join_strings(tags, ",")
	print(txt)

func _inspect_script_properties(node:Node) -> void:
#	var props = node.get_script().get_script_property_list()
	var allProps = node.get_property_list()
	print("Found " + str(allProps.size()))
	
	var props = []
	for prop in allProps:
		var propName:String = prop.name
		if prop.type == PROP_TYPE_STRING && propName.begins_with(("ent_")) && propName.to_lower().contains("tags"):
#			print(str(prop.name) + " type: " + str(prop.type))
			props.push_back(prop.name)
	print(str(props))
	pass

func edit_node(node) -> void:
	if !node.has_method("get_actor_proxy_info"):
		print("Node has no get_actor_proxy_info method")
		return
	var info:Dictionary = node.get_actor_proxy_info()
	print("Editing type: " + str(info.meta.prefab))
	
	var proxies = get_tree().get_nodes_in_group(ZqfActorProxyEditor.GroupName)
	print("Found " + str(proxies.size()) + " proxies")
	
	_inspect_script_properties(node)
	
	for child in node.get_children():
		if child is TagsField:
			print("Found tag field " + child.name)
			var button = _buttonType.instantiate()
			_dockFieldsRoot.add_child(button)
			button.name = "Edit Tags: '" + child.name + "'"
			button.text = button.name
			button.connect("custom_pressed", _on_edit_field)
			
	pass
