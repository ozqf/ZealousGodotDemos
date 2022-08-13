extends RigidBodyProjectile
class_name PrjFlak

onready var _area:Area = $Area

func _ready() -> void:
	_area.connect("area_entered", self, "on_area_entered")
	_area.connect("body_entered", self, "on_body_entered")
	_hitInfo.damage = 20
	_hitInfo.hyperLevel = 1

func on_area_entered(area:Area) -> void:
	if area.get_collision_mask_bit(Interactions.ACTORS):
	# if Interactions.is_obj_a_mob(area):
		var response = Interactions.hit(_hitInfo, area)
		if response == Interactions.HIT_RESPONSE_ABSORBED:
			remove_self()

func on_body_entered(body) -> void:
	if body.get_collision_mask_bit(Interactions.ACTORS):
	# if Interactions.is_obj_a_mob(body):
		var response = Interactions.hit(_hitInfo, body)
		if response == Interactions.HIT_RESPONSE_ABSORBED:
			remove_self()

func _spawn_now() -> void:
	._spawn_now()
	linear_velocity = _velocity
	pass
