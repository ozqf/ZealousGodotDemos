extends CharacterBody3D
class_name PlayerAvatarMelee

signal avatar_event(sourceNode, evType, dataObj)

@onready var _bodyShape:CollisionShape3D = $CollisionShape3D
@onready var _display:Node3D = $model
@onready var _meleePods = $melee_pods
@onready var _gunPods = $gun_pods
@onready var _hitbox:HitBox = $hitbox

var _meleeMode:bool = true

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var _dashDir:Vector3 = Vector3()
var _dashTick:float = 0.0
var _dashJuice:float = 99.0

func _ready() -> void:
	_hitbox.teamId = Game.TEAM_ID_PLAYER
	_hitbox.connect("health_depleted", _on_health_depleted)

func teleport(_transform:Transform3D) -> void:
	self.emit_signal("avatar_event", self, Game.AVATAR_EVENT_TYPE_TELEPORT, _transform)

func _on_health_depleted() -> void:
	self.emit_signal("avatar_event", self, Game.AVATAR_EVENT_TYPE_DIED, null)

func activate(resumeVelocity:Vector3, meleeMode:bool = true) -> void:
	_meleeMode = meleeMode
	_bodyShape.disabled = false
	#_display.visible = true
	self.velocity = resumeVelocity
	_gunPods.set_show_lasers(!meleeMode)

func deactivate() -> void:
	_bodyShape.disabled = true
	_gunPods.set_show_lasers(false)
	#_display.visible = false

func get_right_fist() -> Node3D:
	return _meleePods.get_right_fist()

func get_left_fist() -> Node3D:
	return _meleePods.get_left_fist()

func get_right_gun() -> Node3D:
	return _gunPods.get_right()

func get_left_gun() -> Node3D:
	return _gunPods.get_left()

func _process(_delta:float) -> void:
	if _dashJuice < 99.0:
		_dashJuice += (99.0 / 4) * _delta
		if _dashJuice > 99.0:
			_dashJuice = 99.0

func input_process(_input:PlayerInput, _delta:float) -> void:
	_meleePods.update_yaw(_input.yaw)
	_gunPods.update_yaw(_input.yaw)
	_gunPods.update_aim_point(_input.aimPoint)

func write_hud_info(hudInfo:HudInfo) -> void:
	hudInfo.healthPercentage = _hitbox.get_health_percentage()
	hudInfo.staminaPercentage = _dashJuice

func input_physics_process(_input:PlayerInput, _delta:float) -> void:
	var isOnFloor:bool = self.is_on_floor()
	var pushDir:Vector3 = _input.pushDir
	if _dashTick > 0.0:
		_dashTick -= _delta
		velocity = _dashDir * 20.0
		self.move_and_slide()
		return
	else:
		if _input.dash && isOnFloor && _dashJuice > 33 && !pushDir.is_zero_approx():
			_dashJuice -= 33
			_dashTick = 0.2
			_hitbox.evadeTick = 0.2
			_dashDir = pushDir.normalized()
			velocity = _dashDir * 20.0
			self.move_and_slide()
			return
	#if _meleePods.is_attacking():
	#	pushDir = Vector3()
	var curVelocity:Vector3 = self.velocity
	var curSpeed:float = self.velocity.length()

	if isOnFloor:
		if curSpeed > 7 || pushDir.is_zero_approx():
			curSpeed *= 0.85
			curVelocity = curVelocity.limit_length(curSpeed)
		#elif _meleePods.is_attacking():
		#	curSpeed *= 0.7
	
	var pushStr:float = 80.0
	if !isOnFloor:
		pushStr = 10.0
	elif _meleePods.is_attacking():
		pushStr = 1.0
		curVelocity *= 0.9
	curVelocity += pushDir * pushStr * _delta

	curVelocity += Vector3(0, -gravity, 0) * _delta

	if _input.hookState == HookShot.STATE_GRAPPLE_POINT:
		var toward:Vector3 = _input.hookPosition - self.global_position
		var dist:float = toward.length()
		toward = toward.normalized()
		var weight:float = dist / 40.0
		var strength:float = lerp(0, 100, clampf(weight, 0, 1))
		curVelocity += toward * strength * _delta
	
	if isOnFloor:
		if Input.is_action_just_pressed("move_up"):
			curVelocity.y = 10.0
	
	# moves cancel vertical movement!
	#if _meleeMode:
	#	if _meleePods.read_input(_input) && !isOnFloor:
	#		curVelocity.y = 3.0
	#	# if _input.attack1:
	#	# 	if _meleePods.jab() && !isOnFloor:
	#	# 		curVelocity.y = 4.0
	#else:
	#	_gunPods.read_input(_input)
	if _meleeMode:
		_meleePods.read_input(_input)
	else:
		_gunPods.read_input(_input)

	self.velocity = curVelocity

	self.move_and_slide()

