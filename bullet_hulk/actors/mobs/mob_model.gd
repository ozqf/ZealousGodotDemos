extends Node3D
class_name MobModel

func hit_flinch(_weight:float = 0.5) -> void:
	pass

func muzzle_flash(_index:int = 0) -> void:
	pass

func aim_weapon(_index:int = 0, _windUpTime:float = 1.0) -> void:
	pass

func end_aim_weapon() -> void:
	pass

func is_aiming(_index:int = 0) -> bool:
	return false

func play_fire() -> void:
	pass

func die() -> void:
	pass
