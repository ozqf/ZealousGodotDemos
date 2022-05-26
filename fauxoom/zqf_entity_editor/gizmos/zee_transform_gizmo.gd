extends Spatial

const EdEnums = preload("res://zqf_entity_editor/zee_enums.gd")

enum TransformMode {
	None,
	RotateYaw,
	ScaleX,
	ScaleY,
	ScaleZ
}

onready var _rotate:Spatial = $rotate
onready var _pivot:Spatial = $rotate/handle_pivot
onready var _pivotHandle:Spatial = $rotate/handle_pivot/handle
onready var _3dCursor:Spatial = $rotate/centre/cursor3d

onready var _scale:Spatial = $scale
onready var _xAxisHandle:Spatial = $scale/x
onready var _yAxisHandle:Spatial = $scale/y
onready var _zAxisHandle:Spatial = $scale/z

var _proxy:ZEEEntityProxy = null
var _enabled:bool = false
var _zeeRootMode:int = -1
var _dragPlane:Plane = Plane.PLANE_XZ
var _dragStartPos:Vector3 = Vector3()
var _dragEndPos:Vector3 = Vector3()
var _dragStartScale:Vector3 = Vector3()
var _dragging:bool = false
var _nextTransformMode = TransformMode.None
var _currentTransformMode = TransformMode.None

func _ready():
	add_to_group(EdEnums.GROUP_NAME)

func _set_next_mode(newTransformMode) -> void:
	if _nextTransformMode != TransformMode.None:
		return
	_nextTransformMode = newTransformMode

func _clear_next_mode(transformModeToClear) -> void:
	if _nextTransformMode != transformModeToClear:
		return
	_nextTransformMode = TransformMode.None

func _set_current_mode(transformMode) -> void:
	_currentTransformMode = transformMode

func _enable() -> void:
	_enabled = true
	visible = true

func _disable() -> void:
	_enabled = false
	visible = false
	_dragging = false
	_currentTransformMode = TransformMode.None
	_nextTransformMode = TransformMode.None
	pass

func zee_on_root_mode_changed(_newMode) -> void:
	_zeeRootMode = _newMode
	if _zeeRootMode == EdEnums.RootMode.Rotate || _zeeRootMode == EdEnums.RootMode.Scale:
		_enable()
		return
	_disable()

func zee_on_new_entity_proxy(newProxy) -> void:
	_proxy = newProxy
	_refresh_rotation_display()
	# var yaw:float = _proxy.get_prefab_yaw_degrees()
	# _pivot.rotation_degrees = Vector3(0, yaw, 0)
	# _3dCursor.rotation_degrees = Vector3(0, yaw, 0)

func zee_on_clear_entity_selection() -> void:
	_proxy = null

func zee_on_global_enabled() -> void:
	if _zeeRootMode == EdEnums.RootMode.Rotate || _zeeRootMode == EdEnums.RootMode.Scale:
		_enable()
		return

func zee_on_global_disabled() -> void:
	_disable()

func _cast_ray_to_horizontal():
	var t:Transform = _proxy.get_prefab_transform()

	_dragPlane.d = t.origin.y
	# cast ray to drag plane
	var cursorPos:Vector2 = get_viewport().get_mouse_position()
	var cam:Camera = get_viewport().get_camera()
	var dir:Vector3 = cam.project_ray_normal(cursorPos)
	var result = _dragPlane.intersects_ray(cam.global_transform.origin, dir)
	return result

func _find_next_drag_handle() -> void:
	var cursorPos:Vector2 = get_viewport().get_mouse_position()
	var cam:Camera = get_viewport().get_camera()
	var dir:Vector3 = cam.project_ray_normal(cursorPos)
	var origin:Vector3 = cam.global_transform.origin
	var mask:int = (1 << 21)
	var result = ZqfUtils.hitscan_by_direction_3D(self, origin, dir, 1000.0, ZqfUtils.EMPTY_ARRAY, mask)
	if !result:
		_nextTransformMode = TransformMode.None
		return
	var col = result.collider
	if col == _pivotHandle:
		_set_next_mode(TransformMode.RotateYaw)
	elif col == _xAxisHandle:
		_set_next_mode(TransformMode.ScaleX)
	elif col == _yAxisHandle:
		_set_next_mode(TransformMode.ScaleY)
	elif col == _zAxisHandle:
		_set_next_mode(TransformMode.ScaleZ)
	else:
		_nextTransformMode = TransformMode.None
		return
	pass

func _refresh_rotation_display() -> void:
	if !ZqfUtils.is_obj_safe(_proxy):
		return
	var yaw:float = _proxy.get_prefab_yaw_degrees()
	_pivot.rotation_degrees = Vector3(0, yaw, 0)
	_3dCursor.rotation_degrees = Vector3(0, yaw, 0)
	_scale.rotation_degrees = Vector3(0, yaw, 0)

#####################################################
# update drags
#####################################################
func _tick_yaw(pos:Vector3) -> void:
	_dragEndPos = pos
	var degrees:float = rad2deg(ZqfUtils.yaw_between(_dragStartPos, _dragEndPos))
	degrees = ZqfUtils.snap_f(degrees, 45.0)
	_proxy.set_prefab_yaw(degrees)
	_refresh_rotation_display()
	# _pivot.rotation_degrees = Vector3(0, degrees, 0)
	# _3dCursor.rotation_degrees = Vector3(0, degrees, 0)

func _tick_scale(pos:Vector3) -> void:
	_dragEndPos = pos
	var normal:Vector3
	var rot:Basis = _proxy.get_prefab_basis()
	var resultScaling:Vector3 = Vector3()
	if _currentTransformMode == TransformMode.ScaleX:
		normal = rot.x
		resultScaling.x = 1
	elif _currentTransformMode == TransformMode.ScaleY:
		normal = rot.y
		resultScaling.y = 1
	else:
		normal = rot.z
		resultScaling.z = 1
	
	var dist:float = _dragStartPos.distance_to(_dragEndPos)
	if dist < 0.25:
		dist = 0.0
	dist = ZqfUtils.snap_f(dist, 0.25)
	# dist = ZqfUtils.clamp_float(dist, 0.25, 1000.0)

	var between:Vector3 = _dragEndPos - _dragStartPos
	
	var dp:float = between.dot(normal)
	if dp < 0.0:
		dist = -dist

	var scale = _dragStartScale

	scale.x += (dist * resultScaling.x)
	scale.y += (dist * resultScaling.y)
	scale.z += (dist * resultScaling.z)
	
	if scale.x < 0.1:
		scale.x = 0.1
	if scale.y < 0.1:
		scale.y = 0.1
	if scale.z < 0.1:
		scale.z = 0.1
	_proxy.set_prefab_scale(scale)

#####################################################
# start drags, tick input
#####################################################
func _start_drag(pos:Vector3, newMode) -> void:
	_dragging = true
	_dragStartPos = global_transform.origin
	_dragEndPos = pos
	_set_current_mode(newMode)
	print("Start drag " + str(newMode))

func _tick_drag(_delta:float) -> void:
	var result = _cast_ray_to_horizontal()
	if result == null:
		return
	var pos:Vector3 = result as Vector3

	if Input.is_action_just_pressed("editor_control"):
		# move selection
		_proxy.set_prefab_position(pos)
		pass

	if Input.is_action_just_pressed("attack_1"):
		if _nextTransformMode == TransformMode.RotateYaw:
			_pivot.rotation_degrees = Vector3()
			_start_drag(pos, TransformMode.RotateYaw)
		elif _nextTransformMode == TransformMode.ScaleX:
			_dragStartScale = _proxy.get_prefab_scale()
			_start_drag(pos, TransformMode.ScaleX)
		elif _nextTransformMode == TransformMode.ScaleY:
			_dragStartScale = _proxy.get_prefab_scale()
			_start_drag(pos, TransformMode.ScaleY)
		elif _nextTransformMode == TransformMode.ScaleZ:
			_dragStartScale = _proxy.get_prefab_scale()
			_start_drag(pos, TransformMode.ScaleZ)
	
	elif Input.is_action_just_released("attack_1"):
		# end drag
		_dragging = false
		_set_current_mode(TransformMode.None)
		return
	if Input.is_action_pressed("attack_1"):
		if _currentTransformMode == TransformMode.RotateYaw:
			_tick_yaw(pos)
		elif _currentTransformMode == TransformMode.ScaleX:
			_tick_scale(pos)
		elif _currentTransformMode == TransformMode.ScaleY:
			_tick_scale(pos)
		elif _currentTransformMode == TransformMode.ScaleZ:
			_tick_scale(pos)
	pass

func _process(_delta:float) -> void:
	if !_enabled:
		return
	if _proxy == null:
		return
	
	var t:Transform = _proxy.get_prefab_transform()
	global_transform.origin = t.origin
	# _3dCursor.rotation_degrees = _proxy.rotation_degrees
	
	_find_next_drag_handle()
	_tick_drag(_delta)
