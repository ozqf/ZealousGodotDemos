extends Node3D
class_name AudioService

var _audioOmniType = preload("res://audio/quick_sound.tscn")
var _audio3dType = preload("res://audio/quick_sound_3d.tscn")

func _get_omni_source() -> AudioStreamPlayer:
	var source = _audioOmniType.instantiate()
	self.add_child(source)
	return source

func quick_play_omni(_stream:AudioStream, dbOffset:float = 0.0, delay:float = 0.0) -> AudioStreamPlayer:
	var source:SoundPlayerOmni = _get_omni_source()
	source.custom_play(_stream, dbOffset, delay)
# 	source.stream = _stream
# 	source.play(0)
# #	source.volume_db = 10.0
# 	source.tick = _stream.get_length() + 1.0
	return source

func _get_3d_source() -> AudioStreamPlayer3D:
	var source = _audio3dType.instantiate()
	self.add_child(source)
	return source

func quick_play_3d(pos:Vector3, _stream:AudioStream, dbOffset:float = 0.0, delay:float = 0.0) -> AudioStreamPlayer3D:
	var source:SoundPlayer3D = _get_3d_source()
	# source.set_attenuation_model(AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE)
	# source.stream = _stream
	# source.play(0)
	source.global_transform.origin = pos
	source.custom_play(_stream, dbOffset, delay)
	# source.volume_db = 10.0
	# source.tick = _stream.get_length() + 1.0
	return source

