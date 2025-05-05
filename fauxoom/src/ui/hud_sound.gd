extends Node

# audio players
@onready var _audio:AudioStreamPlayer = $AudioStreamPlayer
@onready var _audio2:AudioStreamPlayer = $AudioStreamPlayer2
@onready var _pickupAudio:AudioStreamPlayer = $audio_pickup

var _pickupSample:AudioStream = preload("res://assets/sounds/item/item_generic.wav")
var _respawnSample:AudioStream = preload("res://assets/sounds/item/item_respawn.wav")
var _reloadSample:AudioStream = preload("res://assets/sounds/item/weapon_reload.wav")
var _reloadSample2:AudioStream = preload("res://assets/sounds/item/weapon_reload_light.wav")

var _baseVolumeDb:float = 0.0

func _ready() -> void:
	pass

func play_stream_weapon_1(stream:AudioStream, pitchAlt:float = 0.0) -> void:
	_audio.pitch_scale = randf_range(1 - pitchAlt, 1 + pitchAlt)
	_audio.stream = stream
	_audio.play()

func play_stream_weapon_2(stream:AudioStream, pitchAlt:float = 0.0, plusDb:float = 0.0) -> void:
	_audio2.pitch_scale = randf_range(1 - pitchAlt, 1 + pitchAlt)
	_audio2.volume_db = plusDb
	_audio2.stream = stream
	#_audio2.vol
	_audio2.play()

func play_weapon_pickup() -> void:
	_pickupAudio.stream = _reloadSample
	_pickupAudio.play()

func play_item_pickup() -> void:
	_pickupAudio.stream = _pickupSample
	_pickupAudio.play()
