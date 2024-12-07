extends Control
class_name MobStatus

@onready var _bar1:ProgressBar = $ProgressBar
@onready var _bar2:ProgressBar = $ProgressBar2
@onready var _bar3:ProgressBar = $ProgressBar3
@onready var _bar4:ProgressBar = $ProgressBar4
@onready var _defenceIcon:AnimatedSprite2D = $defence_icon

func update_stats(health:float, defence:float, power:float, stunTime:float, defenceless:bool) -> void:
	_bar1.value = health
	_bar2.value = defence
	_bar3.value = power
	
	_bar4.value = stunTime
	_defenceIcon.frame = 1 if defenceless else 0

func _process(delta):
	var node:Node3D = (self.get_parent() as Node3D)
	if node == null:
		return
	var cam:Camera3D = ZqfUtils.get_camera_for_node(node)
	var screenOffsetY:Vector2 = Vector2(0, -192)
	self.position = ZqfUtils.world_to_screen(node.global_position, cam) + screenOffsetY
