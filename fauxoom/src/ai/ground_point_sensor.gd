extends RayCast
class_name GroundPointSensor

var _tick:float = 0.0
var _navMeshCheckThreshold:float = 1.0 / 10.0

var isValid:bool = false

func _physics_process(_delta) -> void:
	var canSeeGround:bool = false
	canSeeGround  = self.is_colliding()
	if !canSeeGround:
		visible = false
		isValid = false
		return
	visible = true
	isValid = true
	# this check is very expensive. nav mesh query +
	# all sensors on all mobs are firing it!
	_tick += _delta
	if _tick >= _navMeshCheckThreshold:
		_tick = 0.0
		var selfPos:Vector3 = global_transform.origin
		var point:Vector3 = AI.find_closest_navmesh_point(selfPos)
		if selfPos.distance_to(point) < 0.5:
			visible = true
			isValid = true
		else:
			visible = false
			isValid = false
