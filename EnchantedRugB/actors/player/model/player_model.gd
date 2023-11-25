extends Node
class_name PlayerModel

@onready var _base:Node3D = $base
@onready var _top:Node3D = $top
@onready var _topAnimations:AnimationPlayer = $top/AnimationPlayer

@onready var _loopArea1 = $top/loop/player_leg/Area3D
@onready var _loopArea2 = $top/loop/player_leg/player_leg2/Area3D
@onready var _loopArea3 = $top/loop/player_leg/player_leg2/player_leg3/Area3D
@onready var _loopArea4 = $top/loop/player_leg/player_leg2/player_leg3/player_leg4/Area3D

var _currentSwingAnim:String = ""
var _hitInfo:HitInfo

func _ready() -> void:
	_topAnimations.connect("animation_finished", _on_anim_finished)
	_loopArea1.connect("on_melee_hit", _on_melee_hit)
	_loopArea2.connect("on_melee_hit", _on_melee_hit)
	_loopArea3.connect("on_melee_hit", _on_melee_hit)
	_loopArea4.connect("on_melee_hit", _on_melee_hit)
	_hitInfo = Game.new_hit_info()
	_hitInfo.damage = 100
	_hitInfo.teamId = Game.TEAM_ID_PLAYER

func _on_melee_hit(attackArea, victimArea) -> void:
	print("Saw melee hit by " + str(attackArea) + " against " + str(victimArea))
	Game.try_hit(_hitInfo, victimArea)

func is_attacking() -> bool:
	return _currentSwingAnim != ""

func _on_anim_finished(animName:String) -> void:
	if _currentSwingAnim == "":
		return
	print("Anim finished " + animName)
	_currentSwingAnim = ""

func update_base_yaw(_yaw:float) -> void:
	if is_attacking():
		return
	var degrees:Vector3 = Vector3(0, _yaw, 0)
	_base.rotation_degrees = degrees

func update_top_yaw(_yaw:float) -> void:
	if is_attacking():
		return
	var degrees:Vector3 = Vector3(0, _yaw, 0)
	_top.rotation_degrees = degrees

func swing_loop() -> void:
	if is_attacking():
		return
	_currentSwingAnim = "loop"
	_topAnimations.play(_currentSwingAnim)
