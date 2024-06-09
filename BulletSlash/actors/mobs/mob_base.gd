#@implements IMob IActor IHittable
extends CharacterBody3D
class_name MobBase

@onready var _spawnInfo:MobSpawnInfo = $MobSpawnInfo
@onready var _display:Node3D = $display
@onready var _hitbox:Area3D = $hitbox
@onready var _bodyShape:CollisionShape3D = $CollisionShape3D

func _run_spawn() -> void:
	print("MobBase run spawn")
	var t:Transform3D = Transform3D.IDENTITY
	t.origin = _spawnInfo.t.origin
	self.global_transform = _spawnInfo.t
	_bodyShape.disabled = false
	_hitbox.monitorable = true
	_hitbox.monitoring = true
	_display.visible = true

func _physics_process(_delta:float) -> void:
	var target:TargetInfo = Game.get_player_target()
	if target == null:
		return
	pass

##################################################
# interfaces
##################################################

func get_team_id() -> int:
	return Game.TEAM_ID_ENEMY

func hit(_hitInfo:HitInfo) -> int:
	return 0

func get_spawn_info() -> MobSpawnInfo:
	return _spawnInfo

func spawn() -> void:
	call_deferred("_run_spawn")

func get_id() -> String:
	return ""

func teleport(_transform:Transform3D) -> void:
	pass
