extends Spatial
class_name ZEEMain

const GROUP_NAME:String = "zqf_entity_editor"
const FN_ENABLE:String = "zee_enable"
const FN_DISABLE:String = "zee_disable"

const EdEnums = preload("res://zqf_entity_editor/zee_enums.gd")
var _ent_t = preload("res://zqf_entity_editor/zee_entity.tscn")
var _button_t = preload("res://zqf_entity_editor/ui/zee_button.tscn")

const EXTENSION:String = ".ents"

onready var _leftPanelRoot = $CanvasLayer/left_sidebar_root
onready var _modeLabel:Label = $CanvasLayer/left_sidebar_root/mode_label
onready var _templateListButtons:Control = $CanvasLayer/left_sidebar_root/template_list/buttons
onready var _templateName:Control = $CanvasLayer/left_sidebar_root/template_list/buttons/current_template_name
onready var _fileUI:Control = $CanvasLayer/left_sidebar_root/file_ui_container
onready var _fileUILoad:Button = $CanvasLayer/left_sidebar_root/file_ui_container/load
onready var _fileUISave:Button = $CanvasLayer/left_sidebar_root/file_ui_container/save
onready var _modalBlocker:Control = $CanvasLayer/modal
onready var _fileDialog:FileDialog = $CanvasLayer/modal/FileDialog

onready var _ray:RayCast = $camera/RayCast
onready var _3dCursor:Spatial = $cursor3d
onready var _entsRoot:Spatial = $ents
onready var _cameraControl = $camera
onready var _camera:Camera = $camera/Camera

onready var _entList = $entity_list

var _canPlaceEnt:bool = false
var _flyCamera:bool = true
var _rootMode = EdEnums.RootMode.File
var _templateIndex:int = -1
var _enabled:bool = false

var _templates = [
	{
		name = "player_start",
		label = "Player Start",
		ShapeType = EdEnums.ShapeType.Actor
	},
	{
		name = "weapon_rack",
		label = "Weapon Rack",
		ShapeType = EdEnums.ShapeType.Point
	},
	{
		name = "ammo_pack",
		label = "Ammo Pack",
		ShapeType = EdEnums.ShapeType.Point
	},
	{
		name = "mob_spawn",
		label = "Mob Spawn",
		ShapeType = EdEnums.ShapeType.Actor
	}
]

func _ready() -> void:
	add_to_group(GROUP_NAME)
	_set_fly_camera_on(false)
	for i in range(0, _templates.size()):
		var template = _templates[i]
		_add_button(_templateListButtons, template.name, template.label, "_template_button_clicked")
	_set_root_mode(EdEnums.RootMode.File)
	_modalBlocker.visible = false

	_entList.zee_ent_list_init($ents)

	_fileUILoad.connect("clicked", self, "_file_button_clicked")
	_fileUISave.connect("clicked", self, "_file_button_clicked")
	
	_fileDialog.connect("modal_closed", self, "_file_modal_closed")
	_fileDialog.connect("popup_hide", self, "_file_modal_closed")
	_fileDialog.connect("file_selected", self, "_file_selected")

	disable()

func enable() -> void:
	get_tree().call_group(GROUP_NAME, FN_ENABLE)

func disable() -> void:
	get_tree().call_group(GROUP_NAME, FN_DISABLE)

func zee_enable() -> void:
	_enabled = true
	visible = true
	var uiNodes = $CanvasLayer.get_children()
	for i in range(0, uiNodes.size()):
		uiNodes[i].visible = true
	_modalBlocker.visible = false

func zee_disable() -> void:
	_enabled = false
	visible = false
	var uiNodes = $CanvasLayer.get_children()
	for i in range(0, uiNodes.size()):
		uiNodes[i].visible = false
	_modalBlocker.visible = false

func get_modal_blocking() -> bool:
	if _fileDialog.visible:
		return true
	return false
 
func _file_selected(path:String) -> void:
	if path == "" || path == "user://":
		print("Empty path, aborted")
	if !path.ends_with(EXTENSION):
		path = path + EXTENSION
	print("File selected: " + path)
	_modalBlocker.visible = false
	var mode = _fileDialog.get_mode()

	if mode == FileDialog.MODE_SAVE_FILE:
		# write save
		var data = {}
		data.mapName = Main.get_current_map_name()
		data.ents = _entList.write_ents_list()
		var file = File.new()
		var err = file.open(path, File.WRITE)
		if err != 0:
			print("Error " + str(err) + " opening " + path + " for writing")
			return
		file.store_string(to_json(data))
		file.close()
	else:
		print("No Response to file mode " + str(mode))

func _file_modal_closed() -> void:
	# print("Modal closed")
	_modalBlocker.visible = false

func _add_button(_parent:Control, name:String, label:String, callbackName) -> void:
	var obj = _button_t.instance()
	_parent.add_child(obj)
	obj.connect("clicked", self, callbackName)
	obj.name = name
	obj.text = label

func _template_button_clicked(_button) -> void:
	print("Saw click of " + str(_button.name))

	for i in range(0, _templates.size()):
		var temp = _templates[i]
		if temp.name == _button.name:
			_templateIndex = i
	_refresh_ui()

func _file_button_clicked(_button) -> void:
	if _button.name == "save":
		_open_save_file()
	elif _button.name == "load":
		_open_load_file()

func _set_fly_camera_on(flag:bool) -> void:
	if _flyCamera == flag:
		return
	_flyCamera = flag
	_cameraControl.set_fly_camera_enabled(flag)

func _refresh_ui() -> void:
	if _templateIndex < 0:
		_templateName.text = "No template selected"
		return
	_templateName.text = _templates[_templateIndex].name

func _set_root_mode(newMode) -> void:
	var oldMode = _rootMode
	_rootMode = newMode
	_templateListButtons.visible = false
	_fileUI.visible = false
	var modeTxt = "None"

	if _rootMode == EdEnums.RootMode.File:
		modeTxt = "File"
		_fileUI.visible = true
	elif _rootMode == EdEnums.RootMode.Select:
		modeTxt = "Select"
	elif _rootMode == EdEnums.RootMode.Add:
		_templateListButtons.visible = true
		modeTxt = "Add"
	elif _rootMode == EdEnums.RootMode.LinkTargets:
		modeTxt = "LinkTargets"
	elif _rootMode == EdEnums.RootMode.Scale:
		modeTxt = "Scale"
	
	_modeLabel.text = modeTxt

func _left_click() -> void:
	if _rootMode == EdEnums.RootMode.Add:
		if !_canPlaceEnt:
			return
		var pos:Vector3 = _3dCursor.global_transform.origin
		var template = _templates[_templateIndex]
		_entList.create_entity_at(pos, template)

func _open_save_file() -> void:
	print("Saving " + str(_templates.size()) + " entities")
	_fileDialog.set_mode(FileDialog.MODE_SAVE_FILE)
	_fileDialog.popup()
	_modalBlocker.visible = true

func _open_load_file() -> void:
	print("Load entities")
	_fileDialog.set_mode(FileDialog.MODE_OPEN_FILE)
	_fileDialog.popup()
	_modalBlocker.visible = true

func _process(_delta) -> void:
	if get_modal_blocking():
		return
	if Input.is_action_pressed("attack_2"):
		# fly camera, locked cursor
		_set_fly_camera_on(true)
		pass
	else:
		# static camera, free cursor
		_set_fly_camera_on(false)
		pass
	
	if Input.is_action_just_pressed("slot_1"):
		_set_root_mode(EdEnums.RootMode.File)
	elif Input.is_action_just_pressed("slot_2"):
		_set_root_mode(EdEnums.RootMode.Select)
	elif Input.is_action_just_pressed("slot_3"):
		_set_root_mode(EdEnums.RootMode.Add)
	elif Input.is_action_just_pressed("slot_4"):
		_set_root_mode(EdEnums.RootMode.LinkTargets)
	elif Input.is_action_just_pressed("slot_5"):
		_set_root_mode(EdEnums.RootMode.Scale)
	
	if _flyCamera:
		if _ray.is_colliding():
			# cursor is forward of camera
			var pos:Vector3 = _ray.get_collision_point()
			_3dCursor.global_transform.origin = pos
			# var normal:Vector3 = _ray.get_collision_normal()
			# var lookPos:Vector3 = pos + normal
			# ZqfUtils.look_at_safe(_3dCursor, lookPos)
			_3dCursor.visible = true
			_canPlaceEnt = true
		else:
			_3dCursor.visible = false
			_canPlaceEnt = false
	else:
		# cursor free, cast from camera
		var origin:Vector3 = _camera.global_transform.origin
		var mask:int = 1
		var cursorPos:Vector2 = get_viewport().get_mouse_position()
		var dir:Vector3 = _camera.project_ray_normal(cursorPos)
		var result:Dictionary = ZqfUtils.hitscan_by_direction_3D(_camera, origin, dir, 1000.0, ZqfUtils.EMPTY_ARRAY, mask)
		if result:
			_3dCursor.global_transform.origin = result.position
			_3dCursor.visible = true
			_canPlaceEnt = true
			# var lookPos:Vector3 = result.position + result.normal
			# ZqfUtils.look_at_safe(_3dCursor, lookPos)
			pass
		else:
			_3dCursor.visible = false
			_canPlaceEnt = false

func _is_mouse_over_left_panel() -> bool:
	var pos:Vector2 = get_viewport().get_mouse_position()
	return pos.x < _leftPanelRoot.rect_position.x + _leftPanelRoot.rect_size.x

# Process mouse input via raw input events, if mouse is captured
func _input(_event: InputEvent):
	if get_modal_blocking():
		return
	if _event is InputEventMouseButton:
		var ev = _event as InputEventMouseButton
		
		# print("Mouse ev press index: " + str(ev.get_button_index()))
		if ev.pressed && ev.get_button_index() == 1 && !_is_mouse_over_left_panel():
			_left_click()
			# if _canPlaceEnt && Input.is_action_just_pressed("attack_1"):
			# 	var pos:Vector3 = _3dCursor.global_transform.origin
			# 	_create_entity_at(pos)
			# pass