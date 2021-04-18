extends RigidBody

onready var _sprite = $Sprite3D
onready var _particles = $particles

var _timeToLive:float = 10
var _angleTick:int = 0

func _ready() -> void:
	add_to_group(Groups.GAME_GROUP_NAME)
	launch_gib(Vector3.UP, 1, 0)

func game_on_reset() -> void:
	self.queue_free()

func _run_sprite_spin() -> void:
	_angleTick += 1
	if _angleTick >= 4:
		_angleTick = 0
	if _angleTick == 0:
		_sprite.flip_h = false
		_sprite.flip_v = false
	if _angleTick == 1:
		_sprite.flip_h = true
		_sprite.flip_v = false
	if _angleTick == 2:
		_sprite.flip_h = true
		_sprite.flip_v = true
	if _angleTick == 3:
		_sprite.flip_h = false
		_sprite.flip_v = true

func _process(_delta:float) -> void:
	if self.linear_velocity.length_squared() > 0.5:
		_particles.emitting = true
		_run_sprite_spin()
	else:
		_particles.emitting = false
	

	_timeToLive -= _delta
	if _timeToLive <= 0:
		_timeToLive = 99999
		self.queue_free()

func drop() -> void:
	self.linear_velocity = Vector3()
	self.angular_velocity = Vector3()

func launch_gib(_dir:Vector3, _power:float, ttlOverride:float) -> void:
	if ttlOverride > 0:
		_timeToLive = ttlOverride
	var vel:Vector3 = Vector3()
	_dir.x += rand_range(-0.2, 0.2)
	_dir.y += rand_range(-0.2, 0.2)
	_dir.z += rand_range(-0.2, 0.2)
	# vel.x = _dir.x * 10
	# vel.y = _dir.y * 10
	# vel.z = _dir.z * 10
	vel.x = rand_range(-7, 7) * _power
	vel.y = rand_range(6, 8) * _power
	vel.z = rand_range(-7, 7) * _power
	self.linear_velocity = vel
	
	var minSpin = 1
	var maxSpin = 5
	var angular:Vector3 = Vector3()
	
	angular.x = rand_range(minSpin, maxSpin)
	if randf() > 0.5:
		angular.x *= -1
	
	# tumbling effect when camera attached is too icky with Y enabled
	# angular.y = rand_range(minSpin, maxSpin)
	# if randf() > 0.5:
	# angular.y *= -1
	
	angular.z = rand_range(minSpin, maxSpin)
	if randf() > 0.5:
		angular.z *= -1
	
	self.angular_velocity = angular
	pass

