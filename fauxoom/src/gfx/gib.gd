extends RigidBody

var _timeToLive:float = 10

func _ready() -> void:
	add_to_group(Groups.GAME_GROUP_NAME)
	launch_gib(1, 0)

func game_on_reset() -> void:
	self.queue_free()

func _process(_delta:float) -> void:
	_timeToLive -= _delta
	if _timeToLive <= 0:
		_timeToLive = 99999
		self.queue_free()

func drop() -> void:
	self.linear_velocity = Vector3()
	self.angular_velocity = Vector3()

func launch_gib(_power:float, ttlOverride:float) -> void:
	if ttlOverride > 0:
		_timeToLive = ttlOverride
	var vel:Vector3 = Vector3()
	# vel.x = 0.5 * _power
	vel.y = 10 * _power
	# vel.z = 0.5 * _power
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

