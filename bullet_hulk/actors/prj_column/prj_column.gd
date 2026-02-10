extends Node3D
class_name PrjColumn

@onready var _launch:PrjLaunchInfo = $PrjLaunchInfo

var _tick:float = 0.0

func _physics_process(delta: float) -> void:
	_tick += delta
	if _tick >= 10.0:
		self.queue_free()
	var t:Transform3D = self.global_transform
	var f:Vector3 = -t.basis.z
	var p:Vector3 = t.origin
	p += (f * _launch.speed) * delta
	self.global_position = p
	

func get_launch_info() -> PrjLaunchInfo:
	return _launch

func launch_projectile() -> void:
	self.global_position = _launch.origin
	self.look_at(_launch.origin + _launch.forward)
	if _launch.rollDegrees != 0.0:
		var t:Transform3D = self.global_transform
		self.rotate(t.basis.z, deg_to_rad(_launch.rollDegrees))
