extends Node3D
class_name MeleePod

@onready var _fistArea:Area3D = $fist_area
@onready var _fistCollider:CollisionShape3D = $fist_area/CollisionShape3D

@onready var _bladeArea:Area3D = $blade_area
@onready var _bladeCollider:CollisionShape3D = $blade_area/CollisionShape3D

var _tick:float = 0.0
var _hitInfo:HitInfo

func _ready():
	add_to_group(Game.GROUP_PLAYER_INTERNAL)
	damage_off()
	_hitInfo = Game.new_hit_info()
	_hitInfo.teamId = Game.TEAM_ID_PLAYER
	set_physics_process(false)
	_fistArea.connect("area_entered", _on_area_entered_fist)

func _on_area_entered_fist(_area:Area3D) -> void:
	if _area.has_method("hit"):
		_area.hit(_hitInfo)

func damage_off() -> void:
	_fistCollider.disabled = true
	_bladeCollider.disabled = true

func _physics_process(delta):
	_tick -= delta
	if _tick <= 0.0:
		damage_off()
		set_process(false)
	pass

func plyr_int_melee_attack_started(_move:Dictionary) -> void:
	if _move.is_empty():
		print("Pod " + self.name + " saw empty melee move")
		return
	print("Pod " + self.name + " saw melee move " + str(_move.name))
	_hitInfo.damage = _move.damage
	_tick = _move.duration
	_fistCollider.disabled = false
	set_physics_process(true)
