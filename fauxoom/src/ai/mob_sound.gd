extends AudioStreamPlayer3D
class_name MobSound

# listen to MobBase parent for mob_event signals
func _ready():
	var _r = get_parent().connect("mob_event", self, "on_event")

func on_event(_tag:String, _index:int) -> void:
	pass
