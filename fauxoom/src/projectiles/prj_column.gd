extends Projectile

onready var _up:RayCast = $up_ray
onready var _upMesh:MeshInstance = $up_ray/MeshInstance
onready var _down:RayCast = $down_ray
onready var _downMesh:MeshInstance = $down_ray/MeshInstance

func _process(_delta) -> void:
	# ._process(_delta)
	var pos:Vector3 = global_transform.origin
	var upLength:float = 20.0
	var downLength:float = 20.0
	
	if _up.is_colliding():
		var hit:Vector3 = _up.get_collision_point()
		upLength = pos.distance_to(hit)
	
	if _down.is_colliding():
		var hit:Vector3 = _down.get_collision_point()
		downLength = pos.distance_to(hit)
	
	_upMesh.scale = Vector3(1, upLength, 1)
	_upMesh.transform.origin = Vector3(0, upLength * 0.5, 0)
	_downMesh.scale = Vector3(1, downLength, 1)
	_downMesh.transform.origin = Vector3(0, downLength * 0.5, 0)
	pass
