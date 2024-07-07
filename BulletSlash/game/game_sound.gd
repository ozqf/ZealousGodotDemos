extends Node
class_name GameSound

var _shotgunFire:AudioStream = preload("res://shared/sounds/ssg_fire.wav")
var _shotgunLoad:AudioStream = preload("res://shared/sounds/ssg_open.wav")
var _swingBladeQuick:AudioStream = preload("res://shared/sounds/swing_blade_quick.wav")

@onready var _audio:AudioService = $AudioService

func play_shotgun_fire(pos:Vector3) -> void:
	_audio.quick_play_3d(pos, _shotgunFire)

func play_shotgun_load(pos:Vector3) -> void:
	_audio.quick_play_3d(pos, _shotgunLoad)

func play_quick_blade_swing(pos:Vector3) -> void:
	_audio.quick_play_3d(pos, _swingBladeQuick)
