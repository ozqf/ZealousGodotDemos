extends Node3D
class_name ZqfTimedVisible

var _tick:float = 0.0

func _ready() -> void:
	self.finish()

func finish() -> void:
	self.visible = false
	self.set_physics_process(false)

func start(seconds:float) -> void:
	_tick = seconds
	self.visible = true
	self.set_physics_process(true)

func _physics_process(delta: float) -> void:
	_tick -= delta
	if _tick <= 0.0:
		self.finish()
