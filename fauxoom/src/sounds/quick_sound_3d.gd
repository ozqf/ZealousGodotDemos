extends AudioStreamPlayer3D
class_name QuickSound3D

var _tick:float = 1.0

func quick_play(pos:Vector3, _stream:AudioStream) -> void:
	self.set_attenuation_model(AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE)
	self.stream = _stream
	self.play(0)
	self.global_transform.origin = pos
	self.unit_db = 10.0
	_tick = _stream.get_length() + 1.0
	#print("Spawn sound at " + str(pos) + " for " + str(_tick))

func _process(delta:float) -> void:
	_tick -= delta
	if _tick <= 0.0:
		self.set_process(false)
		self.queue_free()
