extends Node3D

@onready var _cam:PlayerCameraMount = $player_camera_mount
@onready var _ball:PlayerAvatarBall = $player_ball
@onready var _melee = $player_avatar_melee
@onready var _input:PlayerInput = $input
@onready var _rightPod:MeleePod = $right_pod
@onready var _leftPod:MeleePod = $left_pod
@onready var _hookShot:HookShot = $hook_shot
@onready var _hudInfo:HudInfo = $hud_info
@onready var _selfTarInfo:ActorTargetInfo = $actor_target_info

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
		# check for current target
		var collider:CollisionObject3D = _cam.get_aim_collider() as CollisionObject3D
		if collider == null:
			return
		var layer:int = collider.collision_layer
		if layer & Game.HIT_MASK_GRAPPLE_POINT != 0:
			_hookShot.attach_to_grapple(_cam.get_aim_point())
			_rightPod.set_hook_target(_hookShot)
		elif layer & Game.HIT_MASK_GRABBABLE != 0:
			if collider.has_method("receive_grab"):
				var grabbed = collider.receive_grab(_hookShot)
				if grabbed != null:
					print("Grab!")
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
	
	# update targetting info
	_selfTarInfo.position = _melee.global_position
	_selfTarInfo.position = _melee.global_position + Vector3(0, 1, 0)

	# write hud info
	#_hudInfo.healthPercentage = _health.get_health_percentage()
	_melee.write_hud_info(_hudInfo)
	var grp:String = HUD.GROUP_NAME
	var fn:String = HUD.FN_HUD_BROADCAST_INFO
	get_tree().call_group(grp, fn, _hudInfo)

func _change_mode(_newMode:UserPlayMode) -> void:
	#print("Change mode" + str(_newMode))
	var showAimRay:bool = false
	var showRightPod:bool = true
	var showLeftPod:bool = true
	var _prevMode = _mode
	_mode =_newMode
	match _newMode:
		UserPlayMode.Ball:
			showRightPod = false
			showLeftPod = false

			var v:Vector3 = _melee.get_velocity()
			_melee.deactivate()
			_ball.activate(v)
			_cam.set_aim_ray_visible(false)
		UserPlayMode.Melee:
			var v:Vector3 = _ball.get_velocity()
			_ball.deactivate()
			_melee.activate(v, true)

			_rightPod.set_track_target(_melee.get_right_fist())
			_leftPod.set_track_target(_melee.get_left_fist())
		UserPlayMode.Ranged:
			showAimRay = true

			var v:Vector3 = _ball.get_velocity()
			_ball.deactivate()
			_melee.activate(v, false)

			_rightPod.set_track_target(_melee.get_right_gun())
			_leftPod.set_track_target(_melee.get_left_gun())

	_cam.set_aim_ray_visible(showAimRay)
	_rightPod.visible = showRightPod
	_leftPod.visible = showLeftPod

func write_target_info(_tarInfo:ActorTargetInfo) -> bool:
	_tarInfo.isValid = true
	_tarInfo.position = _selfTarInfo.position
	return true

func spawn(_pos:Vector3, _yaw:float = 0) -> void:
	_pos += Vector3(0, 1, 0)
	print("User spawning player at " + str(_pos))
	_cam.global_position = _pos
	_ball.global_position = _pos
	_melee.global_position = _pos
	pass
