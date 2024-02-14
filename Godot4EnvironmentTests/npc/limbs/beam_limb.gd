extends Node3D

var _active:bool = false
var _target:Vector3 = Vector3()

func _ready() -> void:
	off()

func is_active() -> bool:
	return _active

func off() -> void:
	_active = false
	self.visible = false
	self.set_process(false)

func set_target(newTarget:Vector3) -> void:
	_active = true
	self.visible = true
	self.set_process(true)
	_target = newTarget

func get_dist_sqr() -> float:
	return self.global_position.distance_squared_to(_target)

func _process(_delta:float) -> void:
	self.look_at(_target, Vector3.UP)
	var dist:float = self.global_position.distance_to(_target)
	self.scale = Vector3(1, 1, dist)
