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

onready var _scale:Spatial = $scale
onready var _xAxisHandle:Spatial = $scale/x

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
	_pivotHandle.connect("mouse_entered", self, "on_mouse_entered_pivot_handle")
	_pivotHandle.connect("mouse_exited", self, "on_mouse_exited_pivot_handle")

	_xAxisHandle.connect("mouse_entered", self, "on_mouse_entered_x_axis_handle")
	_xAxisHandle.connect("mouse_exited", self, "on_mouse_exited_x_axis_handle")
	pass

func on_mouse_entered_pivot_handle() -> void:
	print("Mouse entered pivot handle")
	_set_next_mode(TransformMode.RotateYaw)

func on_mouse_exited_pivot_handle() -> void:
	print("Mouse exited pivot handle")
	_clear_next_mode(TransformMode.RotateYaw)

func on_mouse_entered_x_axis_handle() -> void:
	print("Mouse entered x axis")
	_set_next_mode(TransformMode.ScaleX)

func on_mouse_exited_x_axis_handle() -> void:
	print("Mouse exited x axis")
	_clear_next_mode(TransformMode.ScaleX)

func _set_next_mode(newTransformMode) -> void:
	if _nextTransformMode != TransformMode.None:
		return
	_nextTransformMode = newTransformMode
	print("Transform mode is " + str(_nextTransformMode))

func _clear_next_mode(transformModeToClear) -> void:
	if _nextTransformMode != transformModeToClear:
		return
	_nextTransformMode = TransformMode.None
	print("Transform mode is " + str(_nextTransformMode))

func _set_current_mode(transformMode) -> void:
	_currentTransformMode = transformMode

func _enable() -> void:
	_enabled = true
	visible = true
	if _zeeRootMode == EdEnums.RootMode.Rotate:
		# _rotate.visible = true
		# _scale.visible = false
		pass
	elif _zeeRootMode == EdEnums.RootMode.Scale:
		# _rotate.visible = false
		# _scale.visible = true
		pass
	pass

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
	pass

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

#####################################################
# update drags
#####################################################
func _tick_yaw(pos:Vector3) -> void:
	_dragEndPos = pos
	var degrees:float = rad2deg(ZqfUtils.yaw_between(_dragStartPos, _dragEndPos))
	degrees = ZqfUtils.snap_f(degrees, 45.0)
	_pivot.rotation_degrees = Vector3(0, degrees, 0)
	_proxy.set_prefab_yaw(degrees)

func _tick_scale_x(pos:Vector3) -> void:
	_dragEndPos = pos
	var dist:float = _dragStartPos.distance_to(_dragEndPos)
	dist = ZqfUtils.snap_f(dist, 0.25)
	dist = ZqfUtils.clamp_float(dist, 0.25, 1000.0)
	var scale = _dragStartScale
	scale.x += dist
	if scale.x < 0.1:
		scale.x = 0.1
	_proxy.set_prefab_scale(scale)

#####################################################
# start drags, tick input
#####################################################
func _start_drag(pos:Vector3, newMode) -> void:
	_pivot.rotation_degrees = Vector3()
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
			_start_drag(pos, TransformMode.RotateYaw)
		elif _nextTransformMode == TransformMode.ScaleX:
			_dragStartScale = _proxy.get_prefab_scale()
			_start_drag(pos, TransformMode.ScaleX)
		
	elif Input.is_action_just_released("attack_1"):
		# end drag
		_dragging = false
		_set_current_mode(TransformMode.None)
		return
	if Input.is_action_pressed("attack_1"):
		if _currentTransformMode == TransformMode.RotateYaw:
			_tick_yaw(pos)
		elif _currentTransformMode == TransformMode.ScaleX:
			_tick_scale_x(pos)
	pass

func _tick_scale(_delta:float) -> void:
	pass

func _process(_delta:float) -> void:
	if !_enabled:
		return
	if _proxy == null:
		return
	
	var t:Transform = _proxy.get_prefab_transform()
	global_transform.origin = t.origin
	
	_tick_drag(_delta)
