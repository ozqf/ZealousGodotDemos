extends RigidBodyProjectile

var _area:Area

func _custom_init() -> void:
	_area = $Area
	_area.set_subject(self)
	_area.connect("area_entered", self, "on_area_entered")
	_area.connect("body_entered", self, "on_body_entered")
	pass

func on_area_entered(area:Area) -> void:
	if Interactions.is_obj_a_mob(area):
		Interactions.hit(_hitInfo, area)

func on_body_entered(body) -> void:
	if Interactions.is_obj_a_mob(body):
		Interactions.hit(_hitInfo, body)
#

func _spawn_now() -> void:
	._spawn_now()
	linear_velocity = _velocity
	pass

func hit(_hitInfo:HitInfo) -> int:
	print("Hyper Core popped!")
	self.queue_free()
	return Interactions.HIT_RESPONSE_ABSORBED
