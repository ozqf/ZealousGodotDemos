extends Node2D

const CAM_SPEED:float = 320.0

onready var _cursor:Node2D = $tile_cursor
onready var _panel:Control = $CanvasLayer/panel
onready var _paintLabel:Label = $CanvasLayer/hud/paint_description

onready var _solidMap:TileMap = $tile_maps/solid
onready var _fenceMap:TileMap = $tile_maps/fence
onready var _solidSlippyMap:TileMap = $tile_maps/solid_slippy
onready var _fenceSlippyMap:TileMap = $tile_maps/fence_slippy
onready var _world:TileMap = $tile_maps/solid

var _panelOn:bool = false
var _paintMode:int = 1

var _tilePos:Vector2 = Vector2()
var _camPos:Vector2 = Vector2()

func _ready():
	get_tree().call_group("game", "on_editor")
	_panel.visible = false
	var _c1 = $CanvasLayer/panel/VBoxContainer/load.connect("pressed", self, "on_click_load")
	var _c2 = $CanvasLayer/panel/VBoxContainer/save.connect("pressed", self, "on_click_save")

func _read_cell_type_at(x: int, y: int) -> int:
	if _solidMap.get_cell(x, y) >= 0:
		return 1
	if _fenceMap.get_cell(x, y) >= 0:
		return 2
	if _solidSlippyMap.get_cell(x, y) >= 0:
		return 3
	if _fenceSlippyMap.get_cell(x, y) >= 0:
		return 4
	return 0

func _measure_map() -> Rect2:
	var r1:Rect2 = _solidMap.get_used_rect()
	var r2:Rect2 = _fenceMap.get_used_rect()
	var r3:Rect2 = _solidSlippyMap.get_used_rect()
	var r4:Rect2 = _fenceSlippyMap.get_used_rect()
	print("Solid rect: " + str(r1))
	print("Fence rect: " + str(r2))
	print("SolidSlippy rect: " + str(r3))
	print("FenceSlippy rect: " + str(r4))
	var r:Rect2 = r1
	r = r.merge(r2)
	r = r.merge(r3)
	r = r.merge(r4)
	return r

func on_click_save():
	print("Editor save")
	var rect := _measure_map()
	print("Result: " + str(rect))
	print(" pos " + str(rect.position) + " end " + str(rect.end) + " size " + str(rect.size))
	for y in range(rect.position.y, rect.end.y):
		for x in range(rect.position.x, rect.end.x):
			var index:int = _read_cell_type_at(x, y)
			if index > 0:
				print("tile type " + str(index) + " at " + str(x) + ", " + str(y))

func on_click_load():
	print("Editor load")

func _set_paint_mode(newMode:int):
	if newMode == 1:
		_world = _solidMap
		_paintLabel.text = "Paint: Solid"
	if newMode == 2:
		_world = _fenceMap
		_paintLabel.text = "Paint: Fence"
	if newMode == 3:
		_world = _solidSlippyMap
		_paintLabel.text = "Paint: Solid - slippy"
	if newMode == 4:
		_world = _fenceSlippyMap
		_paintLabel.text = "Paint: fence - slippy"

func _set_cursor_pos():
	# get world position of cursor
	var mPos := get_global_mouse_position()
	# get tile position of cursor
	_tilePos = _world.world_to_map(mPos)
	# snap cursor to tile pos
	var cursorPos := Vector2(_tilePos.x * 32, _tilePos.y * 32)
	cursorPos += Vector2(16, 16)
	_cursor.position = cursorPos

func _paint_at(tilePos:Vector2):
	_clear_tile_at(tilePos)
	_world.set_cell(int(_tilePos.x), int(_tilePos.y), 0)

func _clear_tile_at(tilePos:Vector2):
	_solidMap.set_cell(int(tilePos.x), int(tilePos.y), -1)
	_fenceMap.set_cell(int(tilePos.x), int(tilePos.y), -1)
	_solidSlippyMap.set_cell(int(tilePos.x), int(tilePos.y), -1)
	_fenceSlippyMap.set_cell(int(tilePos.x), int(tilePos.y), -1)
	pass

func _process_edit_world(_delta:float):
	if Input.is_action_just_pressed("editor_paint_1"):
		_set_paint_mode(1)
	if Input.is_action_just_pressed("editor_paint_2"):
		_set_paint_mode(2)
	if Input.is_action_just_pressed("editor_paint_3"):
		_set_paint_mode(3)
	if Input.is_action_just_pressed("editor_paint_4"):
		_set_paint_mode(4)
	if Input.is_action_pressed("editor_up"):
		_camPos.y -= CAM_SPEED * _delta
	if Input.is_action_pressed("editor_down"):
		_camPos.y += CAM_SPEED * _delta
	if Input.is_action_pressed("editor_left"):
		_camPos.x -= CAM_SPEED * _delta
	if Input.is_action_pressed("editor_right"):
		_camPos.x += CAM_SPEED * _delta
	_set_cursor_pos()
	if Input.is_action_pressed("editor_1"):
		_paint_at(_tilePos)
		#_world.set_cell(_tilePos.x, _tilePos.y, 0)
	if Input.is_action_pressed("editor_2"):
		_clear_tile_at(_tilePos)
		#_world.set_cell(_tilePos.x, _tilePos.y, -1)

func _process(delta):
	if Input.is_action_just_pressed("editor_panel"):
		_panelOn = !_panelOn
		_panel.visible = _panelOn
	if _panelOn:
		pass
	else:
		_process_edit_world(delta)
	pass
