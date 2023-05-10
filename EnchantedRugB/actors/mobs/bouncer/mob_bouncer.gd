extends CharacterBody3D

const SPEED:float = 5.0

@onready var _ray:RayCast3D = $bounce_ray

func _ready():
	pass

func launch() -> void:
	var radians:float = randf_range(0, 360) * ZqfUtils.DEG2RAD
	self.rotation = Vector3(0, radians, 0)
	var vel:Vector3 = (-self.global_transform.basis.z) * SPEED
	self.velocity = vel
#	_ray.target_position = self.velocity.normalized()

func _process(delta):
	if _ray.is_colliding():
		var dir:Vector3 = -self.global_transform.basis.z
		var newDir:Vector3 = dir.bounce(_ray.get_collision_normal())
#		_ray.target_position = newDir
		self.look_at(self.global_position + newDir, Vector3.UP)
		self.velocity = (-self.global_transform.basis.z) * SPEED
	self.move_and_slide()

func _bad_bounce_code() -> void:
	var forward:Vector3 = -self.global_transform.basis.z
	var prevDirection:Vector3 = self.velocity.normalized()
	
	var slides:int = self.get_slide_collision_count()
	for i in range(0, slides):
		var slide:KinematicCollision3D = self.get_slide_collision(i)
		var n:Vector3 = slide.get_normal()
		var dotPrev:float = prevDirection.dot(n)
		if n == Vector3.UP:
			return
		var newDirection:Vector3 = prevDirection.reflect(n)
		var dotNew:float = newDirection.dot(n)
		print("Bounce normal " + str(n) + " old dir " + str(prevDirection) + " new dir " + str(newDirection))
		print("\tPrev dot " + str(dotPrev) + " new dot: " + str(dotNew))
		if newDirection.is_zero_approx():
			print("Empty bounce move")
		self.velocity = newDirection * SPEED
	
	#var last:KinematicCollision3D = self.get_last_slide_collision()
	#if last:
	#	var n:Vector3 = last.get_normal()
	#	if n == Vector3.UP:
	#		return
	#	var newDirection:Vector3 = prevDirection.reflect(n)
	#	self.velocity = newDirection * SPEED
