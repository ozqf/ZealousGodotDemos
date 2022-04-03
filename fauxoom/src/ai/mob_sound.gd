extends AudioStreamPlayer3D
class_name MobSound

# listen to MobBase parent for mob_event signals
func _ready():
	var _r = get_parent().connect("mob_event", self, "on_event")

func play_voice(_stream:AudioStream) -> void:
	stream = _stream
	play(0)

# play with voice player at a higher volume
func play_voice_loud(_stream:AudioStream) -> void:
	stream = _stream
	play(0)
	
func play_equipment(_stream:AudioStream) -> void:
	stream = _stream
	play(0)

func on_event(_tag:String, _index:int) -> void:
	pass
