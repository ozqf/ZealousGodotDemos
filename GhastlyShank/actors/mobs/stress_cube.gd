extends CharacterBody3D

@onready var _animator:AnimationPlayer = $AnimationPlayer
@onready var _debugText:Label3D = $debug_text

var _state:int = Mobs.STATE_NEUTRAL
var _stateTick:float = 0.0
var _stateTime:float = 0.0
var _weightClass:int = Mobs.WEIGHT_CLASS_FODDER

var _gravityStrengthWeight:float = 1.0
var _gravityStrengthDelayTime:float = 1.0

func hit(_incomingHit:HitInfo) -> int:
	print("Stress cube hit")
	if _incomingHit.launchStrength > 0.0:
		#print("Launched!")
		# don't relaunch otherwise multi-directional attacks interfer
		if _state != Mobs.STATE_LAUNCHED:
			begin_launch(_incomingHit.launchYawRadians, _incomingHit.teamId)
	elif _state == Mobs.STATE_JUGGLED:
		if _incomingHit.juggleStrength > 0.0:
			# relaunch
			begin_juggle(_incomingHit.juggleStrength)
		else:
			# hover
			begin_suspend(0.5)
	elif _incomingHit.juggleStrength > 0.0:
		#print("Juggled!")
		begin_juggle(_incomingHit.juggleStrength)
	return 1

func begin_juggle(strength:float = 10.0) -> void:
	_state = Mobs.STATE_JUGGLED
	#self.velocity.y = strength
	#if strength < 1.0:
	#	_gravityStrengthWeight = 0.0
	self.velocity = Vector3(0, strength, 0)

func begin_suspend(strength:float = 1.0) -> void:
	_state = Mobs.STATE_JUGGLED
	#self.velocity.y = strength
	if strength < 1.0:
		_gravityStrengthWeight = 0.0
	self.velocity = Vector3(0, strength, 0)

func begin_fallen() -> void:
	_stateTick = 1.0
	_state = Mobs.STATE_FALLEN

func begin_rising() -> void:
	_stateTick = 1.0
	_state = Mobs.STATE_NEUTRAL

func begin_launch(_yaw:float, _launchingTeamId:int = 0) -> void:
	
	_state = Mobs.STATE_LAUNCHED
	var speed:float = 20.0
	match _weightClass:
		Mobs.WEIGHT_CLASS_PLAYER:
			_stateTime = 0.2
			speed = 15.0
		_:
			_stateTime = 2.0
	_stateTick = _stateTime
	self.velocity = Vector3(-sin(_yaw) * speed, 0, -cos(_yaw) * speed)

const GRAVITY_MPS:float = 10.0

func calc_gravity() -> float:
	return GRAVITY_MPS * _gravityStrengthWeight

func _refresh_debug_text() -> void:
	var stateName:String = "neutral"
	match _state:
		Mobs.STATE_JUGGLED:
			stateName = "juggled"
		Mobs.STATE_FALLEN:
			stateName = "fallen"
		Mobs.STATE_RISING:
			stateName = "rising"
		Mobs.STATE_LAUNCHED:
			stateName = "launched"
	var txt:String = stateName
	txt += "\nTick " + str(_stateTick)
	_debugText.text = txt

func _physics_process(_delta: float) -> void:
	_refresh_debug_text()
	if _gravityStrengthWeight < 1.0:
		_gravityStrengthWeight += _gravityStrengthDelayTime * _delta
		if _gravityStrengthWeight > 1.0:
			_gravityStrengthWeight = 1.0
	match _state:
		Mobs.STATE_NEUTRAL:
			var drag:Vector3 = ZqfUtils.calc_drag_vector3(self.velocity, 5.0, _delta)
			self.velocity += drag
			self.velocity.y += -calc_gravity() * _delta
			self.move_and_slide()
		Mobs.STATE_JUGGLED:
			if self.is_on_floor() && self.velocity.y <= 0.0:
				begin_fallen()
				return
			self.velocity.y += -calc_gravity() * _delta
			self.move_and_slide()
		Mobs.STATE_FALLEN:
			if !self.is_on_floor():
				begin_juggle(1.0)
				return
			_stateTick -= _delta
			if _stateTick <= 0.0:
				begin_rising()
			else:
				var drag:Vector3 = ZqfUtils.calc_drag_vector3(self.velocity, 5.0, _delta)
				self.velocity += drag
				self.velocity.y += -calc_gravity() * _delta
				self.move_and_slide()
		Mobs.STATE_RISING:
			_stateTick -= _delta
			if _stateTick <= 0.0:
				_stateTick = _stateTime
				_state = Mobs.STATE_NEUTRAL
		Mobs.STATE_LAUNCHED:
			_stateTick -= _delta
			if _stateTick <= 0.0:
				begin_fallen()
				return
			
			var results:KinematicCollision3D = self.move_and_collide(self.velocity * _delta)
			if results != null:
				var l:int = results.get_collision_count()
				for i in range(0, l):
					var obj:Object = results.get_collider(i)
					if "collision_layer" in obj:
						var layer:int = obj.collision_layer
						if (layer & (1 << 0)) == 1:
							begin_juggle(3.5)
							var n:Vector3 = results.get_normal(i)
							n *= 5.0
							# force pop up
							self.global_position.y += 0.2
							n.y = 5.0
							self.velocity = n
							print("Begin fall, vel " + str(n))
							break;
				return
