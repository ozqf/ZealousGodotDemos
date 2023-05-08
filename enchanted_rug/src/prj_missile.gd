extends KinematicBody

export var inactive:bool = false

var _velocity:Vector3 = Vector3()
var _hitInfo:HitInfo

var _noLosTick:float = 0.0

func _ready() -> void:
	# var _foo = self.connect("body_entered", self, "on_body_entered")
	_hitInfo = Main.new_hit_info()

func die() -> void:
	inactive = true
	self.queue_free()

func on_body_entered(body) -> void:
	if inactive:
		return
	var layer = body.get_collision_layer()
	#print("layer: " + str(layer))
	if (layer & 1) > 0:
		print("Missile touch die")
		die()

func hit(info:HitInfo) -> void:
	print("Missile hit by team " + str(info.teamId))
	if inactive:
		return
	if info.teamId != Interactions.TEAM_ENEMY:
		print("Missile kill!")
		die()

func _physics_process(_delta:float):
	if inactive:
		return
	var tar:Dictionary = Main.get_target()
	if tar.valid == false:
		#die()
		return
	var pos:Vector3 = global_transform.origin

	if pos.distance_to(tar.position) < 3.0:
		print("Missile hit")
		die()
		return
	
	var speed:float = _velocity.length()
	var accelRate:float = 10.0
	
	# turn if we can see the player
	if ZqfUtils.los_check(self, pos, tar.position, 1):
		_noLosTick = 0.0
		var toward:Vector3 = (tar.position - pos).normalized()
		var forward:Vector3 = _velocity.normalized()
		var newDir:Vector3 = forward.linear_interpolate(toward, 0.02)
		newDir = newDir.normalized()

		# accelerate if facing target, decelerate if not
		if forward.dot(toward) > 0.5:
			speed += (accelRate * _delta)
			var tarSpeed:float = tar.velocity.length()
			var maxClosingSpeed:float = 50.0
			# don't accelerate too far over the player's own velocity.
			if speed > (tarSpeed + maxClosingSpeed):
				speed = tarSpeed + maxClosingSpeed
		else:
			speed -= (accelRate * _delta)
			if speed < 1.0:
				speed = 1.0

		_velocity = newDir * speed
	else:
		_velocity += Vector3.UP * (10.0 * _delta)
		_noLosTick += _delta
		if _noLosTick > 30.0:
			print("Missile timeout")
			die()
			return
	# global_transform.origin += (_velocity * _delta)
	_velocity = move_and_slide(_velocity)
#	var lookAtPos:Vector3 = global_transform.origin + _velocity
#	var up:Vector3 = Vector3.UP
#	ZqfUtils.look_at_safe(self, lookAtPos)

func prj_launch(_launchInfo:PrjLaunchInfo) -> void:
	global_transform.origin = _launchInfo.origin
	_velocity = _launchInfo.forward * 50.0
	_hitInfo.teamId = _launchInfo.teamId
	pass
