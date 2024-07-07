extends AudioStreamPlayer3D
class_name SoundPlayer3D

const STATE_IDLE = 0
const STATE_PLAYING = 1
const STATE_WAITING = 2

var _state:int = 0
var _tick:float = 0.0

func _play_stream() -> void:
	# source.set_attenuation_model(AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE)
	self.play(0)
	_tick = stream.get_length() + 1.0
	_state = STATE_PLAYING

func custom_play(
	_stream:AudioStream,
	dbOffset:float = 0.0,
	delay:float = 0.0
	) -> void:
	self.stream = _stream
	self.volume_db = dbOffset
	self.max_db = dbOffset
	if delay <= 0.0:
		_play_stream()
	else:
		_tick = delay
		_state = STATE_WAITING

func _physics_process(_delta:float) -> void:
	if _state == STATE_PLAYING:
		_tick -= _delta
		if _tick <= 0.0:
			_state = STATE_IDLE
			self.queue_free()
	elif _state == STATE_WAITING:
		_tick -= _delta
		if _tick <= 0.0:
			_play_stream() 
