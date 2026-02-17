extends Node3D
class_name MobModel

var _timeSinceLastFlinch:float = 0.0

func set_mob_prefab(_prefabName:String) -> void:
	pass

func set_weapon_rotation(_index:int, _rollDegrees:float) -> void:
	pass

func hit_flinch(_weight:float = 0.5) -> void:
	_timeSinceLastFlinch = 0.0

func muzzle_flash(_index:int) -> void:
	pass

func aim_weapon(_index:int, _windUpTime:float = 1.0) -> void:
	pass

func is_aiming(_index:int) -> bool:
	return false

func end_aim_weapon() -> void:
	pass

func play_fire() -> void:
	pass

func die() -> void:
	pass

func _physics_process(_delta:float) -> void:
	_timeSinceLastFlinch += _delta
