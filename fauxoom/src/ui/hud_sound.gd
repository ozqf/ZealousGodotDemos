extends Node

# audio players
onready var _audio:AudioStreamPlayer = $AudioStreamPlayer
onready var _audio2:AudioStreamPlayer = $AudioStreamPlayer2
onready var _pickupAudio:AudioStreamPlayer = $audio_pickup

var _pickupSample:AudioStream = preload("res://assets/sounds/item/item_generic.wav")
var _respawnSample:AudioStream = preload("res://assets/sounds/item/item_respawn.wav")
var _reloadSample:AudioStream = preload("res://assets/sounds/item/weapon_reload.wav")
var _reloadSample2:AudioStream = preload("res://assets/sounds/item/weapon_reload_light.wav")


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func play_stream_weapon_1(stream:AudioStream, pitchAlt:float = 0.0) -> void:
	_audio.pitch_scale = rand_range(1 - pitchAlt, 1 + pitchAlt)
	_audio.stream = stream
	_audio.play()

func play_weapon_pickup() -> void:
	_pickupAudio.stream = _reloadSample
	_pickupAudio.play()

func play_item_pickup() -> void:
	_pickupAudio.stream = _pickupSample
	_pickupAudio.play()
	
