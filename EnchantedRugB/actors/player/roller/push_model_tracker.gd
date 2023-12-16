extends Node3D

var _pushDir:Vector3 = Vector3()

func _ready():
	pass

func refresh(_input:PlayerInput) -> void:
	_pushDir = _input.pushDir
	pass

func _process(_delta:float) -> void:
	if _pushDir.is_equal_approx(Vector3.ZERO):
		self.visible = false
		return
	self.visible = true
	var target:Vector3 = get_parent().global_position + (-_pushDir)
	self.global_position = (self.global_position as Vector3).lerp(target, 0.7)
	ZqfUtils.look_at_safe(self, get_parent().global_position)
