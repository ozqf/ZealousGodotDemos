extends RigidBody

func _ready() -> void:
	launch(1)

func launch(_power:float) -> void:
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
	
#	angular.y = rand_range(minSpin, maxSpin)
#	if randf() > 0.5:
#		angular.y *= -1
	
	angular.z = rand_range(minSpin, maxSpin)
	if randf() > 0.5:
		angular.z *= -1
	
	self.angular_velocity = angular
	pass

