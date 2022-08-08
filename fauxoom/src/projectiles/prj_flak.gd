extends RigidBodyProjectile
class_name PrjFlak

onready var _area:Area = $Area

func _ready() -> void:
	_area.connect("area_entered", self, "on_area_entered")
	_area.connect("body_entered", self, "on_body_entered")
	_hitInfo.damage = 20
	_hitInfo.hyperLevel = 1

func on_area_entered(area:Area) -> void:
	if Interactions.is_obj_a_mob(area):
		if Interactions.hit(_hitInfo, area) > 0:
			# Game.spawn_blood_spurt(area.global_transform.origin)
			pass

func on_body_entered(body) -> void:
	if Interactions.is_obj_a_mob(body):
		if Interactions.hit(_hitInfo, body) > 0:
			# Game.spawn_blood_spurt(body.global_transform.origin)
			pass

func _spawn_now() -> void:
	._spawn_now()
	linear_velocity = _velocity
	pass
