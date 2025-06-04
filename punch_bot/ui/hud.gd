extends Control
class_name HUD

const GROUP_NAME:String = "hud"
# params: hudInfo:HudInfo
const FN_HUD_BROADCAST_INFO:String = "hud_broadcast_info"

@onready var _health:ProgressBar = $health
@onready var _stamina:ProgressBar = $stamina

func _ready() -> void:
	self.add_to_group(GROUP_NAME)

func hud_broadcast_info(_info:HudInfo) -> void:
	_health.value = _info.healthPercentage
	_stamina.value = _info.staminaPercentage
