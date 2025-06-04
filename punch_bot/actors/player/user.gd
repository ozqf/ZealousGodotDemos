extends Node3D

var _camMountType = preload("res://actors/player/player_camera_mount.tscn")
var _meleeAvatarType = preload("res://actors/player/player_avatar_melee.tscn")
var _ballAvatarType = preload("res://actors/player/roller/player_ball.tscn")
var _meleePodType = preload("res://actors/player/model/melee_pod.tscn")
var _hookshotType = preload("res://actors/player/hook_shot/hook_shot.tscn")

var _corpseSlicedType = preload("res://actors/player/corpse/player_corpse_sliced.tscn")

var _cam:PlayerCameraMount
var _ball:PlayerAvatarBall
var _melee:PlayerAvatarMelee
var _rightPod:MeleePod
var _leftPod:MeleePod
var _hookShot:HookShot

@onready var _input:PlayerInput = $input
@onready var _hudInfo:HudInfo = $hud_info
@onready var _selfTarInfo:ActorTargetInfo = $actor_target_info

enum UserPlayMode { Unspawned, Ball, Melee, Ranged }
var _mode:UserPlayMode = UserPlayMode.Unspawned

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
	if _mode == UserPlayMode.Unspawned:
		return
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
	
	# mode switching
	if _can_change_mode():
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
	
	if _hookShot.is_attached():
		_hookShot.refresh_tether(_melee.global_transform)


func _hookshot_input(input:PlayerInput) -> void:
	if input.grab && !_hookShot.is_attached():
		# check for current target
		var collider:CollisionObject3D = _cam.get_aim_collider() as CollisionObject3D
		if collider == null:
			return
		var layer:int = collider.collision_layer
		if layer & Game.HIT_MASK_GRAPPLE_POINT != 0:
			var dist:float = _melee.global_position.distance_to(_cam.get_aim_point())
			if dist > Game.PLAYER_GRAPPLE_RANGE:
				return
			_hookShot.attach_to_grapple(_cam.get_aim_point())
			_rightPod.set_hook_target(_hookShot)
			if _mode == UserPlayMode.Ball:
				_rightPod.visible = true
		elif layer & Game.HIT_MASK_GRABBABLE != 0:
			if collider.has_method("receive_grab"):
				var grabbed = collider.receive_grab(_hookShot)
				if grabbed != null:
					print("Grab!")
	elif !input.grab && _hookShot.is_attached():
		_hookShot.release()
		_rightPod.set_hook_target(null)
		if _mode == UserPlayMode.Ball:
			_rightPod.visible = false

func _physics_process(_delta:float) -> void:
	if _mode == UserPlayMode.Unspawned:
		return
	
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
	_input.isGrounded = _melee.is_on_floor()

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

func _can_change_mode() -> bool:
	match _mode:
		UserPlayMode.Melee:
			return _melee.can_change_away()
		_:
			return true

func _change_mode(_newMode:UserPlayMode) -> void:
	#print("Change mode" + str(_newMode))
	var showAimRay:bool = false
	var showRightPod:bool = true
	var showLeftPod:bool = true
	var _prevMode = _mode
	_mode =_newMode
	match _newMode:
		UserPlayMode.Ball:
			showRightPod = _hookShot.is_attached()
			showLeftPod = true

			var v:Vector3 = _melee.get_velocity()
			_melee.deactivate()
			_ball.activate(v)
			_cam.set_aim_ray_visible(false)

			_leftPod.set_track_target(_ball.get_push_melee_pod_tracker())
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
		UserPlayMode.Unspawned:
			_cam.queue_free()
			_ball.queue_free()
			_melee.queue_free()
			_rightPod.queue_free()
			_leftPod.queue_free()
			_hookShot.queue_free()
			_mode = UserPlayMode.Unspawned
			return

	_cam.set_aim_ray_visible(showAimRay)
	_rightPod.visible = showRightPod
	_leftPod.visible = showLeftPod

func write_target_info(_tarInfo:ActorTargetInfo) -> bool:
	_tarInfo.isValid = true
	_tarInfo.position = _selfTarInfo.position
	return true

func die() -> void:
	if _mode == UserPlayMode.Unspawned:
		return
	_change_mode(UserPlayMode.Unspawned)
	var corpse = _corpseSlicedType.instantiate()
	Zqf.get_actor_root().add_child(corpse)
	corpse.spawn(_melee.global_transform, _cam.get_camera_transform())

func teleport(newTransform:Transform3D) -> void:
	newTransform.origin.y += 0.5
	_melee.global_transform = newTransform
	_ball.global_transform = newTransform

func spawn(_pos:Vector3, _yaw:float = 0) -> void:
	_pos += Vector3(0, 1, 0)
	print("User spawning player at " + str(_pos))

	_cam = _camMountType.instantiate()
	add_child(_cam)
	
	_rightPod = _meleePodType.instantiate()
	_rightPod.name = "right_pod"
	add_child(_rightPod)
	#_rightPod.connect("melee_pod_event", _on_melee_pod_event)
	
	_leftPod = _meleePodType.instantiate()
	_leftPod.name = "left_pod"
	add_child(_leftPod)
	#_leftPod.connect("melee_pod_event", _on_melee_pod_event)
	
	_ball =  _ballAvatarType.instantiate()
	add_child(_ball)
	_ball.connect("avatar_event", _on_avatar_event)
	
	_melee = _meleeAvatarType.instantiate()
	add_child(_melee)
	_melee.connect("avatar_event", _on_avatar_event)
	_melee.set_pods(_rightPod, _leftPod)
	#_melee.attach_animation_key_callback(_on_animation_key)

	_hookShot = _hookshotType.instantiate()
	add_child(_hookShot)

	_cam.global_position = _pos
	_ball.global_position = _pos
	_melee.global_position = _pos
	_change_mode(UserPlayMode.Melee)

func _on_avatar_event(__sourceNode, __evType, __dataObj) -> void:
	match __evType:
		Game.AVATAR_EVENT_TYPE_DIED:
			die()
		Game.AVATAR_EVENT_TYPE_TELEPORT:
			if __dataObj is Transform3D:
				teleport(__dataObj)
