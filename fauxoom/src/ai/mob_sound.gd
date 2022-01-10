extends AudioStreamPlayer3D
class_name MobSound

# Called when the node enters the scene tree for the first time.
func _ready():
	var _r = get_parent().connect("mob_event", self, "on_event")

func on_event(tag:String, _index:int) -> void:
	pass
