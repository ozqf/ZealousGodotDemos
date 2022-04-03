extends Projectile

onready var _up:RayCast = $up_ray
onready var _upMesh:MeshInstance = $up_ray/MeshInstance
onready var _upArea:Area = $up_ray/Area
onready var _down:RayCast = $down_ray
onready var _downMesh:MeshInstance = $down_ray/MeshInstance
onready var _downArea:Area = $down_ray/Area

func _ready() -> void:
	_upArea.connect("body_entered", self, "_body_entered_up")
	_downArea.connect("body_entered", self, "_body_entered_down")

func _process(_delta) -> void:
	# ._process(_delta)
	var pos:Vector3 = global_transform.origin
	var upLength:float = 20.0
	var downLength:float = 20.0
	_hitInfo.damage = 1
	
	if _up.is_colliding():
		var hit:Vector3 = _up.get_collision_point()
		upLength = pos.distance_to(hit)
		# sometimes colliding flag is set but collider is null...
		var collider = _up.get_collider()
		if collider != null:
			if (collider.get_collision_layer() & Interactions.get_entity_mask()) != 0:
				Interactions.hit(_hitInfo, _up.get_collider())
	
	if _down.is_colliding():
		var hit:Vector3 = _down.get_collision_point()
		downLength = pos.distance_to(hit)
		# sometimes colliding flag is set but collider is null...
		var collider = _down.get_collider()
		if collider != null:
			if (collider.get_collision_layer() & Interactions.get_entity_mask()) != 0:
				Interactions.hit(_hitInfo, _down.get_collider())
	
	_upMesh.scale = Vector3(1, upLength, 1)
	_upMesh.transform.origin = Vector3(0, upLength * 0.5, 0)
	_downMesh.scale = Vector3(1, downLength, 1)
	_downMesh.transform.origin = Vector3(0, downLength * 0.5, 0)
	pass

func _body_entered_up(body) -> void:
	if body.name == "player":
		print("Column up hit")
	#Interactions.hit(_hitInfo, body)
	pass

func _body_entered_down(body) -> void:
	if body.name == "player":
		print("Column down hit")
	#Interactions.hit(_hitInfo, body)
	pass

func launch_prj(origin:Vector3, _forward:Vector3, sourceId:int, prjTeam:int, collisionMask:int) -> void:
	.launch_prj(origin, _forward, sourceId, prjTeam, collisionMask)

	var flatVel:Vector3 = _velocity

	flatVel.y = 0
	ZqfUtils.look_at_safe(self, origin + flatVel)
