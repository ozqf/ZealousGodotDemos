extends Spatial

const MOUSE_CLAIM:String = "editor"

onready var _camera:Camera = $Camera
var _cameraStart:Transform
var _cameraSpeed:float = 20

func _ready() -> void:
	print("Flat Map Editor init")
	_cameraStart = _camera.global_transform
	MouseLock.add_claim(get_tree(), MOUSE_CLAIM)

func _process_click() -> void:
	var mouse:Vector2 = get_viewport().get_mouse_position()
	var origin:Vector3 = _camera.project_ray_origin(mouse)
	var dir:Vector3 = _camera.project_ray_normal(mouse)
	print("Fire ray")
	var result = ZqfUtils.hitscan_by_pos_3D(self, origin, dir, 1000, [], -1)
	if result:
		var pos:Vector3 = result.position
		print("Mouse hit at X/Z " + str(pos.x) + ", " + str(pos.z))

func _input(event):
	# Mouse in viewport coordinates.
	if event is InputEventMouseButton:
		print("Mouse Click/Unclick at: ", event.position)
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
