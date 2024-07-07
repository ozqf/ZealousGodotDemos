extends Node
class_name GameSound

var _ssgSound:AudioStream = preload("res://shared/sounds/ssg_fire.wav")

@onready var _audio:AudioService = $AudioService

func play_shotgun_fire(pos:Vector3) -> void:
	_audio.quick_play_3d(pos, _ssgSound)
