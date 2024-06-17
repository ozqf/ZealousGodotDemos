extends Control
class_name Hud

@onready var _shotCount:Label = $shot_count_label

func _ready():
	self.add_to_group(HudInfo.GROUP_NAME)

func hud_info_broadcast(hudInfo:HudInfo) -> void:
	_shotCount.text = "SHOTS: " + str(hudInfo.shotCount)
