extends NavigationAgent3D
class_name ZqfNavAgent

@export var moveSpeed:float = 5.0
var _moveTarget:Vector3 = Vector3()

func set_move_target(pos:Vector3) -> void:
	_moveTarget = pos
	self.set_target_position(pos)
	pass

func physics_tick(_delta:float) -> bool:
	if self.is_navigation_finished():
		return false
	
	var curPos:Vector3 = get_parent().global_position
	var nextPos:Vector3 = self.get_next_path_position()
	velocity = curPos.direction_to(nextPos) *  moveSpeed
	return true
