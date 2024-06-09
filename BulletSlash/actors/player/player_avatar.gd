extends CharacterBody3D
class_name PlayerAvatar

@onready var _cursor:Node3D = $cursor
@onready var _aimPlanePos:Node3D = $aim_plane_pos
@onready var _display:Node3D = $display
@onready var _animator:AnimationPlayer = $display/AnimationPlayer
@onready var _rightBatonArea:Area3D = $display/right_hand/right_baton/hitbox
@onready var _leftBatonArea:Area3D = $display/left_hand/left_baton/hitbox
var _groundPlane:Plane = Plane()

var _targetInfo:TargetInfo
var _lastAimPoint:Vector3 = Vector3()

func _ready() -> void:
	_targetInfo = Game.new_target_info()
	_animator.play("punch_idle")
	_rightBatonArea.connect("area_entered", _on_area_entered_right_baton)
	_leftBatonArea.connect("area_entered", _on_area_entered_left_baton)
	var grp = Game.GROUP_GAME_EVENTS
	var fn = Game.GAME_EVENT_FN_PLAYER_SPAWNED
	get_tree().call_group(grp, fn, self)

func _on_area_entered_right_baton(_area:Area3D) -> void:
	print("Right baton hit")

func _on_area_entered_left_baton(_area:Area3D) -> void:
	print("Left baton hit")

func _set_area_on(area:Area3D, flag:bool) -> void:
	area.monitoring = flag
	area.monitorable = flag

func right_baton_on() -> void:
	_set_area_on(_rightBatonArea, true)

func right_baton_off() -> void:
	_set_area_on(_rightBatonArea, false)

func left_baton_on() -> void:
	_set_area_on(_leftBatonArea, true)

func left_baton_off() -> void:
	_set_area_on(_leftBatonArea, false)

func get_target_info() -> TargetInfo:
	return _targetInfo

func _exit_tree():
	var grp = Game.GROUP_GAME_EVENTS
	var fn = Game.GAME_EVENT_FN_PLAYER_DESPAWNED
	get_tree().call_group(grp, fn, self)

func look_at_aim_point() -> void:
	var displayPos:Vector3 = _display.global_position
	displayPos.y = _lastAimPoint.y
	_display.look_at(_lastAimPoint, Vector3.UP)

func is_view_locked() -> bool:
	match _animator.current_animation:
		"punch_idle":
			return false
		"blaster_idle":
			return false
		"":
			return false
		null:
			return false
		_:
			return true

func _process(_delta:float) -> void:
	_groundPlane.normal = Vector3.UP
	_groundPlane.d = _aimPlanePos.global_position.y
	var mouse_pos = get_viewport().get_mouse_position()
	var camera:Camera3D = get_viewport().get_camera_3d()
	var origin = camera.project_ray_origin(mouse_pos)
	var direction = camera.project_ray_normal(mouse_pos)
	_lastAimPoint = _groundPlane.intersects_ray(origin, direction)
	_cursor.global_position = _lastAimPoint
	
	if !is_view_locked():
		look_at_aim_point()

func _physics_process(_delta:float) -> void:
	
	if _animator.current_animation == "punch_spin_test":
		var pos:float = _animator.current_animation_position
		if Input.is_action_pressed("attack_3") && pos >= 0.4 && pos <= 0.45:
			_animator.seek(0.2)
	
	var isAttacking:bool = is_view_locked()
	
	if !isAttacking && Input.is_action_just_pressed("attack_1"):
		look_at_aim_point()
		_animator.play("punch_jab_left")
		_animator.queue("punch_idle")
	
	if !isAttacking && Input.is_action_just_pressed("attack_2"):
		look_at_aim_point()
		_animator.play("blaster_idle")
	
	if !isAttacking && Input.is_action_just_pressed("attack_3"):
		look_at_aim_point()
		_animator.play("punch_spin_test")
		_animator.queue("punch_idle")
	
	if !is_view_locked():
		var vec:Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		var move:Vector3 = Vector3(vec.x, 0, vec.y) * 5.0
		self.velocity = move
		self.move_and_slide()
