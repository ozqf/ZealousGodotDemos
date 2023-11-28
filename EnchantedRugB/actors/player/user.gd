extends Node3D

@onready var _cam:PlayerCameraMount = $player_camera_mount
@onready var _ball:PlayerAvatarBall = $player_ball
@onready var _melee = $player_avatar_melee
@onready var _input:PlayerInput = $input
@onready var _rightPod:MeleePod = $right_pod
@onready var _leftPod:MeleePod = $left_pod
@onready var _hookShot:HookShot = $hook_shot

enum UserPlayMode { Ball, Melee, Ranged }
var _mode:UserPlayMode = UserPlayMode.Ball

func _ready() -> void:
	pass

func _move_trackers(target:Node3D, _cameraNode:Node3D, other:Node3D) -> void:
	var origin:Vector3 = _cam.global_position
	var targetPos:Vector3 = target.global_position
	var dest:Vector3 = origin.lerp(targetPos, 0.9)
	_cam.global_position = dest

	if other != null:
		origin = other.global_position
		dest = origin.lerp(targetPos, 0.9)
		other.global_position = dest

func _process(_delta:float) -> void:
	_input.aimPoint = _cam.get_aim_point()
	var origin:Vector3 = _cam.global_position
	var target:Vector3 = _ball.global_position
	var dest:Vector3 = origin.lerp(target, 0.9)
	_cam.global_position = dest

	match _mode:
		UserPlayMode.Ball:
			_move_trackers(_ball, _cam, _melee)
		UserPlayMode.Melee:
			_move_trackers(_melee, _cam, _ball)
			_melee.input_process(_input, _delta)
		UserPlayMode.Ranged:
			_move_trackers(_melee, _cam, _ball)
			_melee.input_process(_input, _delta)
	
	if Input.is_action_just_pressed("slot_1"):
		_change_mode(UserPlayMode.Ball)
	if Input.is_action_just_pressed("slot_2"):
		_change_mode(UserPlayMode.Melee)
	if Input.is_action_just_pressed("slot_3"):
		_change_mode(UserPlayMode.Ranged)

	if Input.is_action_just_pressed("character_stance"):
		match _mode:
			UserPlayMode.Ball:
				_change_mode(UserPlayMode.Melee)
			UserPlayMode.Melee:
				_change_mode(UserPlayMode.Ball) 
	pass

func _hookshot_input(input:PlayerInput) -> void:
	if input.grab && !_hookShot.is_attached():
		_hookShot.attach(_cam.get_aim_point())
		_rightPod.set_hook_target(_hookShot)
	elif !input.grab && _hookShot.is_attached():
		_hookShot.release()
		_rightPod.set_hook_target(null)
	

func _physics_process(_delta:float) -> void:
	var dir:Vector3 = _cam.get_push_direction()
	_input.inputDir = _cam.inputDir
	_input.pushDir = dir
	_input.camera = _cam.get_head_transform()
	_input.yaw = _cam.rotation_degrees.y
	_input.attack1 = Input.is_action_pressed("attack_1")
	_input.attack2 = Input.is_action_pressed("attack_2")
	_input.dash = Input.is_action_pressed("move_down")
	_input.style = Input.is_action_pressed("style")
	_input.grab = Input.is_action_pressed("grab")
	_input.aimPoint = _cam.get_aim_point()

	_hookShot.update_input(_input)

	_hookshot_input(_input)

	match _mode:
		UserPlayMode.Ball:
			_ball.input_physics_process(_input, _delta)
		UserPlayMode.Melee:
			_melee.input_physics_process(_input, _delta)
		UserPlayMode.Ranged:
			_melee.input_physics_process(_input, _delta)

func _change_mode(_newMode:UserPlayMode) -> void:
	#print("Change mode" + str(_newMode))
	var _prevMode = _mode
	_mode =_newMode
	match _newMode:
		UserPlayMode.Ball:
			var v:Vector3 = _melee.get_velocity()
			_melee.deactivate()
			_ball.activate(v)
		UserPlayMode.Melee:
			var v:Vector3 = _ball.get_velocity()
			_ball.deactivate()
			_melee.activate(v, true)

			_rightPod.set_track_target(_melee.get_right_fist())
			#_rightPod.get_parent().remove_child(_rightPod)
			#var hand:Node3D = _melee.get_right_fist()
			#hand.add_child(_rightPod)
			
			_leftPod.set_track_target(_melee.get_left_fist())
			#_leftPod.get_parent().remove_child(_leftPod)
			#hand = _melee.get_left_fist()
			#hand.add_child(_leftPod)
		UserPlayMode.Ranged:
			var v:Vector3 = _ball.get_velocity()
			_ball.deactivate()
			_melee.activate(v, false)

			_rightPod.set_track_target(_melee.get_right_gun())
			#_rightPod.get_parent().remove_child(_rightPod)
			#var hand:Node3D = _melee.get_right_gun()
			#hand.add_child(_rightPod)
			
			_leftPod.set_track_target(_melee.get_left_gun())
			#_leftPod.get_parent().remove_child(_leftPod)
			#hand = _melee.get_left_gun()
			#hand.add_child(_leftPod)
	pass

func spawn(_pos:Vector3, _yaw:float = 0) -> void:
	print("User spawning player at " + str(_pos))
	pass
