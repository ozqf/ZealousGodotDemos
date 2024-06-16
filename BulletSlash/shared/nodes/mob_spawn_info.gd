extends Node
class_name MobSpawnInfo

var uuid:String = ""
var t:Transform3D = Transform3D.IDENTITY

func _ready() -> void:
	uuid = UUID.v4()
