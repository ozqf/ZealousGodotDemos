extends Node3D

@onready var _cam:PlayerCameraMount = $player_camera_mount
@onready var _ball:PlayerAvatarBall = $player_ball
@onready var _melee = $player_avatar_melee
@onready var _input:PlayerInput = $input

enum UserPlayMode { Ball, Melee }
var _mode:UserPlayMode = UserPlayMode.Ball

func _move_trackers(target:Node3D, cam:Node3D, other:Node3D) -> void:
	var origin:Vector3 = _cam.global_position
	var targetPos:Vector3 = target.global_position
	var dest:Vector3 = origin.lerp(targetPos, 0.9)
	_cam.global_position = dest

	if other != null:
		origin = other.global_position
		dest = origin.lerp(targetPos, 0.9)
		other.global_position = dest

func _process(_delta:float) -> void:
	var origin:Vector3 = _cam.global_position
	var target:Vector3 = _ball.global_position
	var dest:Vector3 = origin.lerp(target, 0.9)
	_cam.global_position = dest

	match _mode:
		UserPlayMode.Ball:
			_move_trackers(_ball, _cam, _melee)
			pass
		UserPlayMode.Melee:
			_move_trackers(_melee, _cam, _ball)
			pass

	if Input.is_action_just_pressed("character_stance"):
		match _mode:
			UserPlayMode.Ball:
				_change_mode(UserPlayMode.Melee)
			UserPlayMode.Melee:
				_change_mode(UserPlayMode.Ball) 
	pass

func _change_mode(_newMode:UserPlayMode) -> void:
	print("Change mode" + str(_newMode))
	var _prevMode = _mode
	_mode =_newMode
	match _newMode:
		UserPlayMode.Ball:
			_ball.activate()
			_melee.deactivate()
		UserPlayMode.Melee:
			_ball.deactivate()
			_melee.activate()

	pass

func _physics_process(_delta:float) -> void:
	var dir:Vector3 = _cam.get_push_direction()
	_input.pushDir = dir
	_input.camera = _cam.get_head_transform()
	match _mode:
		UserPlayMode.Ball:
			_ball.input_physics_process(_input, _delta)
		UserPlayMode.Melee:
			_melee.input_physics_process(_input, _delta)

func spawn(_pos:Vector3, _yaw:float = 0) -> void:
	print("User spawning player at " + str(_pos))
	pass
