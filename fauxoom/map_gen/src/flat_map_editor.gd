extends Spatial

const MOUSE_CLAIM:String = "editor"

enum EditMode { Grid, Entities }

onready var _grid:GridEditor = $grid_editor
onready var _ents:EntityEditor = $entity_editor

onready var _cursor:Spatial = $cursor
onready var _camera:Camera = $Camera

var _mapDef:MapDef
var _cameraStart:Transform
var _cameraSpeed:float = 20
var _cursorGridPos:Vector2 = Vector2()
var _mode = EditMode.Grid

func _ready() -> void:
	print("Flat Map Editor init")
	add_to_group("game")
	_cameraStart = _camera.global_transform
	MouseLock.add_claim(get_tree(), MOUSE_CLAIM)
	# _mapDef = AsciMapLoader.build_test_map()
	_mapDef = MapEncoder.empty_map(32, 32)
	_mapDef.set_all(1)
	_grid.init(_mapDef)
	_ents.set_map_def(_mapDef)

	# initial state
	_grid.set_active(true)
	_ents.set_active(false)

func _exit_tree():
	MouseLock.remove_claim(get_tree(), MOUSE_CLAIM)

func on_save_map_text() -> void:
	# var b64 = AsciMapLoader.str_to_b64(_mapText)
	var b64:String = MapEncoder.map_to_b64(_mapDef)
	get_tree().call_group("game", "on_wrote_map_text", b64)

func _set_cursor_by_grid_pos(x:int, y:int) -> void:
	var hSize:float = _mapDef.scale * 0.5
	var pos:Vector3 = Vector3((x * _mapDef.scale) + hSize, 0, (y * _mapDef.scale) + hSize)
	var t:Transform = _cursor.global_transform
	t.origin = pos
	_cursor.global_transform = t

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
	var result = ZqfUtils.hitscan_by_pos_3D(self, origin, dir, 1000, [], (1 << 19))
	if result:
		_update_cursor(result.position)

func _unhandled_input(event):
	# Mouse in viewport coordinates.
	if event is InputEventMouseButton && event.pressed:
		if _mode == EditMode.Grid:
			_grid.process_click()
		elif _mode == EditMode.Entities:
			_ents.process_click()

func _input(event):
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
		camMove.y -= 1
		print("Zoom in")
	if Input.is_action_just_released("zoom_out"):
		camMove.y += 1
		print("Zoom out")
	camMove = (camMove * _cameraSpeed) * delta
	
	var t:Transform = _camera.global_transform
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
	_update_camera(delta)
	
	# mode switching
	if Input.is_action_just_pressed("edit_mode_next"):
		_change_mode(EditMode.Entities)
	if Input.is_action_just_pressed("edit_mode_prev"):
		_change_mode(EditMode.Grid)
	
	if _mode == EditMode.Grid:
		_grid.update(delta)
	elif _mode == EditMode.Entities:
		_ents.update(delta)
	
