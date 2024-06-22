extends Node
class_name HudInfo

const GROUP_NAME:String = "hud_info"
const FN_HUD_INFO_BROADCAST = "hud_info_broadcast"

var show:bool = true
var playerWorldPosition:Vector3 = Vector3()

var shotCount:int = 0
var maxShotCount:int = 0
