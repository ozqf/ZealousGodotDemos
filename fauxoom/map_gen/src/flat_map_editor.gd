extends Node3D
class_name FlatMapEditor

const MOUSE_CLAIM:String = "editor"
const DEFAULT_MAP_SIZE:int = 24

enum EditMode { Grid, Entities }

@onready var _gridButton:Button = $main_options/mode_select/grid
@onready var _entsButton:Button = $main_options/mode_select/entities

@onready var _grid:GridEditor = $grid_editor
@onready var _ents:MapGenEntityEditor = $entity_editor

@onready var _cursor:Node3D = $cursor
@onready var _camera:Camera3D = $Camera

var _initialised:bool = false
var _mapDef:MapDef
var _cameraStart:Transform3D
var _cameraSpeed:float = 20
var _cursorGridPos:Vector2 = Vector2()
var _mode = EditMode.Grid

var _leftMouseHeld:bool = false
var _rightMousesHold:bool = false

func _ready() -> void:
	pass

func init(newMapDef:MapDef, entityTemplates) -> void:
	if newMapDef == null:
		return
	print("Flat Map Editor init")
	_cameraStart = _camera.global_transform
	MouseLock.add_claim(get_tree(), MOUSE_CLAIM)
	
	_mapDef = newMapDef
	_initialised = true

	_grid.init(_mapDef)
	_ents.init(_mapDef, entityTemplates)

	# initial state
	_grid.set_active(true)
	_ents.set_active(false)

	var _f
	_f = _gridButton.connect("pressed", _on_grid_mode)
	_f = _entsButton.connect("pressed", _on_ents_mode)

func _exit_tree():
	MouseLock.remove_claim(get_tree(), MOUSE_CLAIM)

func _set_cursor_by_grid_pos(x:int, y:int) -> void:
	var hSize:float = _mapDef.scale * 0.5
	var pos:Vector3 = Vector3((x * _mapDef.scale) + hSize, 0, (y * _mapDef.scale) + hSize)
	var t:Transform3D = _cursor.global_transform
	t.origin = pos
	_cursor.global_transform = t

func _on_grid_mode() -> void:
	_change_mode(EditMode.Grid)

func _on_ents_mode() -> void:
	_change_mode(EditMode.Entities)

func _update_cursor(newWorldPos:Vector3) -> void:
	newWorldPos.x += _mapDef.scale * 0.5
	newWorldPos.y = 0
	newWorldPos.z += _mapDef.scale * 0.5
	_cursorGridPos.x = round(newWorldPos.x / _mapDef.scale)
	_cursorGridPos.y = round(newWorldPos.z / _mapDef.scale)
	_cursorGridPos.x -= 1
	_cursorGridPos.y -= 1
	var ix = int(_cursorGridPos.x)
	var iy = int(_cursorGridPos.y)
	_set_cursor_by_grid_pos(ix, iy)
	_grid.update_cursor_pos(ix, iy)
	_ents.update_cursor_pos(ix, iy)

func _update_cursor_pos() -> void:
	var mouse:Vector2 = get_viewport().get_mouse_position()
	var origin:Vector3 = _camera.project_ray_origin(mouse)
	var dir:Vector3 = _camera.project_ray_normal(mouse)
	var result = ZqfUtils.hitscan_by_direction_3D(self, origin, dir, 1000, [], (1 << 19))
	if result:
		_update_cursor(result.position)

func _unhandled_input(event):
	# Mouse in viewport coordinates.
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == MOUSE_BUTTON_LEFT:
				_leftMouseHeld = true
				if _mode == EditMode.Grid:
					_grid.process_click()
				elif _mode == EditMode.Entities:
					_ents.process_click()
			if event.button_index == MOUSE_BUTTON_RIGHT:
				if _mode == EditMode.Grid:
					_grid.process_right_click()
				elif _mode == EditMode.Entities:
					_ents.process_right_click()
		elif !event.pressed:
			if event.button_index == MOUSE_BUTTON_LEFT:
				_leftMouseHeld = false

func _input(event):
	if !_initialised:
		return
	if event is InputEventMouseMotion:
		_update_cursor_pos()

func _update_camera(delta:float) -> void:
	var camMove:Vector3 = Vector3()
	if Input.is_action_pressed("move_left"):
		camMove.x -= 1
	if Input.is_action_pressed("move_right"):
		camMove.x += 1
	if Input.is_action_pressed("move_forward"):
		camMove.z -= 1
	if Input.is_action_pressed("move_backward"):
		camMove.z += 1
	
	if Input.is_action_just_released("zoom_in"):
		camMove.y -= 3
	if Input.is_action_just_released("zoom_out"):
		camMove.y += 3
	camMove = (camMove * _cameraSpeed) * delta
	
	var t:Transform3D = _camera.global_transform
	t.origin += camMove
	_camera.global_transform = t

func _change_mode(newMode) -> void:
	_mode = newMode
	if _mode == EditMode.Grid:
		_grid.set_active(true)
		_ents.set_active(false)
	elif _mode == EditMode.Entities:
		_grid.set_active(false)
		_ents.set_active(true)

func _process(delta) -> void:
	if !_initialised:
		return
	_update_camera(delta)
	
	# mode switching
	# if Input.is_action_just_pressed("edit_mode_next"):
	# 	_change_mode(EditMode.Entities)
	# if Input.is_action_just_pressed("edit_mode_prev"):
	# 	_change_mode(EditMode.Grid)
	if _leftMouseHeld:
		if _mode == EditMode.Grid:
			_grid.process_left_held(delta)
		elif _mode == EditMode.Entities:
			_ents.process_left_held(delta)
	
	if _mode == EditMode.Grid:
		_grid.update(delta)
	elif _mode == EditMode.Entities:
		_ents.update(delta)
	
