extends Area3D
class_name MobMeleeWeapon

var _matBladeOffMat = preload("res://shared/object_materials/laser_sword_off.tres")
var _matBladeOrange = preload("res://shared/object_materials/laser_sword_orange.tres")
var _matBladeRed = preload("res://shared/object_materials/laser_sword_red.tres")

@onready var _bladeMesh:MeshInstance3D = $blade
@onready var _hurtShape:CollisionShape3D = $CollisionShape3D

enum BladeState { Idle, Damaging, Blocking, Off }
var _bladeState:BladeState = BladeState.Idle

func get_blade_state() -> BladeState:
	return _bladeState

func set_blade_state(newState:BladeState) -> void:
	_bladeState = newState
	match _bladeState:
		BladeState.Idle:
			set_blade_idle()
		BladeState.Damaging:
			set_blade_damaging()
		BladeState.Off:
			set_blade_off()
		BladeState.Blocking:
			set_blade_blocking()

func set_blade_idle() -> void:
	_bladeState = BladeState.Idle
	_hurtShape.disabled = true
	_bladeMesh.material_override = _matBladeOrange

func set_blade_blocking() -> void:
	_bladeState = BladeState.Blocking
	_hurtShape.disabled = true
	_bladeMesh.material_override = _matBladeOrange

func set_blade_off() -> void:
	_bladeState = BladeState.Off
	_hurtShape.disabled = true
	_bladeMesh.material_override = _matBladeOffMat

func set_blade_damaging() -> void:
	_bladeState = BladeState.Damaging
	_hurtShape.disabled = false
	_bladeMesh.material_override = _matBladeRed
