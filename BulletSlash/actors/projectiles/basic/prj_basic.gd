#@implements IProjectile
extends Area3D
class_name PrjBasic

@onready var _launchInfo:ProjectileLaunchInfo = $ProjectileLaunchInfo
var _hitInfo:HitInfo

func _ready() -> void:
	_hitInfo = Game.new_hit_info()
	self.connect("area_entered", _on_hitbox_area_entered)

func _on_hitbox_area_entered(_area:Area3D) -> void:
	_hitInfo.direction = -self.global_transform.basis.z
	Game.try_hit(_hitInfo, _area)
	pass

func launch() -> void:
	self.global_position = _launchInfo.origin
	var lookTo:Vector3 = _launchInfo.origin + _launchInfo.forward
	self.look_at(lookTo, Vector3.UP)

func get_launch_info() -> ProjectileLaunchInfo:
	return _launchInfo

func cancel(_cancelMode:int) -> void:
	pass

func _physics_process(_delta:float) -> void:
	var pos:Vector3 = self.global_position
	var dir:Vector3 = -self.global_transform.basis.z
	pos += (dir * 15) * _delta
	self.global_position = pos
