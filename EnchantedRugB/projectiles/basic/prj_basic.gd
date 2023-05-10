extends Area3D

@onready var _timeout:Timer = $Timer
@onready var _worldRay:RayCast3D = $world_ray

var speed:float = 50.0
var _velocity:Vector3 = Vector3()

func launch(origin:Vector3, forward:Vector3) -> void:
	_timeout.wait_time = 2.0
	_timeout.start()
	_timeout.connect("timeout", _on_timeout)
	
	global_position = origin
	self.look_at(origin + forward, Vector3.UP)
	_velocity = (-self.global_transform.basis.z) * speed

func _on_timeout() -> void:
	self.queue_free()

func _on_touch_hitbox(area:Area3D) -> void:
	pass

func _physics_process(_delta:float) -> void:
	if _worldRay.is_colliding():
		self.queue_free()
		self.set_process(false)
		return
	self.global_position += _velocity * _delta
