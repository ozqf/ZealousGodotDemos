extends KinematicBody2D
class_name Actor

var _velocity: Vector2 = Vector2()

func _calc_velocity(_curVel: Vector2, _inputDir: Vector2, _runSpeed:float):
	var result = Vector2()
	if _inputDir.length() == 0:
		return result
	var radians: float = atan2(_inputDir.y, _inputDir.x)
	result.x = cos(radians) * _runSpeed
	result.y = sin(radians) * _runSpeed
	return result
