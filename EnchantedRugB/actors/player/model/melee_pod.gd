extends Node3D
class_name MeleePod

@onready var _fistArea:Area3D = $fist_area
@onready var _fistCollider:CollisionShape3D = $fist_area/CollisionShape3D

@onready var _bladeArea:Area3D = $blade_area
@onready var _bladeCollider:CollisionShape3D = $blade_area/CollisionShape3D

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
		_area.hit(_hitInfo)

func damage_off() -> void:
	_fistCollider.disabled = true
	_bladeCollider.disabled = true

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
	if _tick <= 0.0:
		set_physics_process(false)
		damage_off()
	pass

func set_track_target(newTarget:Node3D) -> void:
	_trackTarget = newTarget

func set_hook_target(newTarget:Node3D) -> void:
	_hookTarget = newTarget

func plyr_int_melee_attack_started(_move:Dictionary) -> void:
	if _move.is_empty():
		print("Pod " + self.name + " saw empty melee move")
		return
	#print("Pod " + self.name + " saw melee move " + str(_move.name))
	_hitInfo.damage = _move.damage
	_hitInfo.flags = _move.flags
	_tick = _move.duration
	_fistCollider.disabled = false
	set_physics_process(true)
