extends Node3D
class_name MeleePod

const POD_EVENT_PARRIED:String = "parried"

signal melee_pod_event(typeStr, meleePod)

var _idleMat = preload("res://shared/object_materials/cyan_glow.tres")
var _activeMat = preload("res://shared/object_materials/laser_sword_red.tres")

@onready var _fistArea:Area3D = $fist_area
@onready var _fistCollider:CollisionShape3D = $fist_area/CollisionShape3D

@onready var _bladeArea:Area3D = $blade_area
@onready var _bladeCollider:CollisionShape3D = $blade_area/CollisionShape3D

@onready var _mesh:MeshInstance3D = $MeshInstance3D

var _tick:float = 0.0
# damage set when a move is activated
var _hitInfo:HitInfo

var _trackTarget:Node3D = null
var _hookTarget:Node3D = null

func _ready():
	add_to_group(Game.GROUP_PLAYER_INTERNAL)
	damage_off()
	_hitInfo = Game.new_hit_info()
	_hitInfo.teamId = Game.TEAM_ID_PLAYER
	set_physics_process(false)
	_fistArea.connect("area_entered", _on_area_entered_fist)

func _on_area_entered_fist(_area:Area3D) -> void:
	if _area.has_method("hit"):
		_hitInfo.hitPosition = self.global_position
		var response:int = _area.hit(_hitInfo)
		if response == Game.HIT_RESPONSE_PARRIED:
			print("Player was parried!")
			self.emit_signal("melee_pod_event", POD_EVENT_PARRIED, self)

func fist_damage_on() -> void:
	_mesh.set_surface_override_material(1, _activeMat)
	_fistCollider.set_deferred("disabled", false)
	_bladeCollider.set_deferred("disabled", true)
	#_fistCollider.disabled = false
	#_bladeCollider.disabled = true

func damage_off() -> void:
	_mesh.set_surface_override_material(1, _idleMat)
	_fistCollider.set_deferred("disabled", true)
	_bladeCollider.set_deferred("disabled", true)
	#_fistCollider.disabled = true
	#_bladeCollider.disabled = true

func _process(_delta:float) -> void:
	if _hookTarget != null:
		var start:Transform3D = self.global_transform
		var end:Transform3D = _hookTarget.global_transform
		self.global_transform = start.interpolate_with(end, 0.4)
	elif _trackTarget != null:
		var start:Transform3D = self.global_transform
		var end:Transform3D = _trackTarget.global_transform
		self.global_transform = start.interpolate_with(end, 0.8)

func _physics_process(delta):
	_tick -= delta
	_hitInfo.direction = -self.global_transform.basis.z
	if _tick <= 0.0:
		set_physics_process(false)
		damage_off()
	pass

func set_track_target(newTarget:Node3D) -> void:
	_trackTarget = newTarget

func set_hook_target(newTarget:Node3D) -> void:
	_hookTarget = newTarget

func plyr_int_melee_attack_started(_move:Dictionary, _sequenceNumber:int) -> void:
	if _move.is_empty():
		print("Pod " + self.name + " saw empty melee move")
		return
	#print("Pod " + self.name + " saw melee move " + str(_move.name))
	_hitInfo.damage = _move.damage
	_hitInfo.flags = _move.flags
	_hitInfo.attackId = str(_sequenceNumber)
	_tick = _move.duration
	#_fistCollider.disabled = false
	set_physics_process(true)
