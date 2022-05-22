extends Spatial

const EdEnums = preload("res://zqf_entity_editor/zee_enums.gd")

onready var _pivot:Spatial = $rotate/handle_pivot

var _proxy:ZEEEntityProxy = null
var _enabled:bool = false
var _zeeRootMode:int = -1
var _dragPlane:Plane = Plane.PLANE_XZ
var _dragStartPos:Vector3 = Vector3()
var _dragEndPos:Vector3 = Vector3()
var _dragging:bool = false

func _ready():
	add_to_group(EdEnums.GROUP_NAME)
	pass

func _enable() -> void:
	_enabled = true
	visible = true
	pass

func _disable() -> void:
	_enabled = false
	visible = false
	_dragging = false
	pass

func zee_on_root_mode_changed(_newMode) -> void:
	_zeeRootMode = _newMode
	if _zeeRootMode == EdEnums.RootMode.Rotate:
		_enable()
		return
	_disable()

func zee_on_new_entity_proxy(newProxy) -> void:
	_proxy = newProxy
	pass

func zee_on_clear_entity_selection() -> void:
	_proxy = null

func zee_on_global_enabled() -> void:
	if _zeeRootMode == EdEnums.RootMode.Rotate:
		_enable()
		return

func zee_on_global_disabled() -> void:
	_disable()

func _process(_delta:float) -> void:
	if !_enabled:
		return
	if _proxy == null:
		return
	var t:Transform = _proxy.get_prefab_transform()
	global_transform.origin = t.origin

	_dragPlane.d = t.origin.y
	# cast ray to drag plane
	var cursorPos:Vector2 = get_viewport().get_mouse_position()
	var cam:Camera = get_viewport().get_camera()
	var dir:Vector3 = cam.project_ray_normal(cursorPos)
	var result = _dragPlane.intersects_ray(cam.global_transform.origin, dir)
	if result == null:
		return
	var pos:Vector3 = result as Vector3
	if Input.is_action_just_pressed("attack_1"):
		_pivot.rotation_degrees = Vector3()
		_dragging = true
		_dragStartPos = global_transform.origin
		_dragEndPos = pos
		print("Start rotate drag " + str(pos))
	elif Input.is_action_just_released("attack_1"):
		# end drag
		_dragging = false
		return
	if Input.is_action_pressed("attack_1"):
		_dragEndPos = pos
		# var vx:float = _dragEndPos.x - _dragStartPos.x
		# var vz:float = _dragEndPos.z - _dragStartPos.z
		var degrees:float = rad2deg(ZqfUtils.yaw_between(_dragStartPos, _dragEndPos))
		degrees = ZqfUtils.snap_f(degrees, 45.0)
		_pivot.rotation_degrees = Vector3(0, degrees, 0)
		_proxy.set_prefab_yaw(degrees)
	# var result:Dictionary = ZqfUtils.hitscan_by_direction_3D(_camera, origin, dir, 1000.0, ZqfUtils.EMPTY_ARRAY, mask)
