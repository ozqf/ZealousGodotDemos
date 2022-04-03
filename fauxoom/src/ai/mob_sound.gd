extends Spatial
class_name MobSound

onready var _voice:AudioStreamPlayer3D = $voice
onready var _equipment:AudioStreamPlayer3D = $equipment

# listen to MobBase parent for mob_event signals
func _ready():
	var _r = get_parent().connect("mob_event", self, "on_event")

func play_voice(_stream:AudioStream) -> void:
	_voice.set_attenuation_model(AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE)
	_voice.stream = _stream
	_voice.play(0)

# play with voice player at a higher volume
func play_voice_loud(_stream:AudioStream) -> void:
	_voice.set_attenuation_model(AudioStreamPlayer3D.ATTENUATION_DISABLED)
	_voice.stream = _stream
	_voice.play(0)
	
func play_equipment(_stream:AudioStream) -> void:
	_equipment.stream = _stream
	_equipment.play(0)

func on_event(_tag:String, _index:int) -> void:
	pass
