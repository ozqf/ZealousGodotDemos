extends Spatial

const MOUSE_CLAIM:String = "editor"

onready var _mapGen:MapGen = $map_gen
onready var _cursor:Spatial = $cursor
onready var _camera:Camera = $Camera

var _mapDef:MapDef
var _cameraStart:Transform
var _cameraSpeed:float = 20
var _cursorGridPos:Vector2 = Vector2()
var _tileSize:int = 2

var _paintType:int = 1

func _ready() -> void:
	print("Flat Map Editor init")
	_cameraStart = _camera.global_transform
	MouseLock.add_claim(get_tree(), MOUSE_CLAIM)
	# _mapDef = AsciMapLoader.build_test_map()
	_mapDef = MapEncoder.empty_map(32, 32)
	_mapGen.build_world_map(_mapDef)

func _set_cursor_by_grid_pos(x:int, y:int) -> void:
	var hSize:float = _tileSize * 0.5
	var pos:Vector3 = Vector3((x * _tileSize) + hSize, 0, (y * _tileSize) + hSize)
	var t:Transform = _cursor.global_transform
	t.origin = pos
	_cursor.global_transform = t

func _update_cursor(newWorldPos:Vector3) -> void:
	newWorldPos.x += _tileSize * 0.5
	newWorldPos.y = 0
	newWorldPos.z += _tileSize * 0.5
	# var t:Transform = _cursor.global_transform
	# t.origin.x = round(newWorldPos.x)
	# t.origin.y = round(newWorldPos.y)
	# t.origin.z = round(newWorldPos.z)
	# _cursor.global_transform = t
	_cursorGridPos.x = round(newWorldPos.x / _tileSize)
	_cursorGridPos.y = round(newWorldPos.z / _tileSize)
	_cursorGridPos.x -= 1
	_cursorGridPos.y -= 1
	_set_cursor_by_grid_pos(_cursorGridPos.x, _cursorGridPos.y)
	print("Click at cell " + str(_cursorGridPos))

func _process_click() -> void:
	var mouse:Vector2 = get_viewport().get_mouse_position()
	var origin:Vector3 = _camera.project_ray_origin(mouse)
	var dir:Vector3 = _camera.project_ray_normal(mouse)
	var result = ZqfUtils.hitscan_by_pos_3D(self, origin, dir, 1000, [], -1)
	if result:
		_update_cursor(result.position)

func _input(event):
	# Mouse in viewport coordinates.
	if event is InputEventMouseButton:
		# print("Mouse Click/Unclick at: ", event.position)
		_process_click()

func _process(delta) -> void:
	var camMove:Vector3 = Vector3()
	if Input.is_action_pressed("move_left"):
		camMove.x -= 1
	if Input.is_action_pressed("move_right"):
		camMove.x += 1
	if Input.is_action_pressed("move_forward"):
		camMove.z -= 1
	if Input.is_action_pressed("move_backward"):
		camMove.z += 1
	camMove = (camMove * _cameraSpeed) * delta
	
	var t:Transform = _camera.global_transform
	t.origin += camMove
	_camera.global_transform = t

func _exit_tree():
	MouseLock.remove_claim(get_tree(), MOUSE_CLAIM)
