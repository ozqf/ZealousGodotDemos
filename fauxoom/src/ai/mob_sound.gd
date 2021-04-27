extends AudioStreamPlayer3D

var _alert1:AudioStream = preload("res://assets/sounds/mob/punk/punk_alert_1.wav")
var _alert2:AudioStream = preload("res://assets/sounds/mob/punk/punk_alert_2.wav")
var _alert3:AudioStream = preload("res://assets/sounds/mob/punk/punk_alert_3.wav")

var _pain:AudioStream = preload("res://assets/sounds/mob/punk/punk_pain.wav")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var _r = get_parent().connect("mob_event", self, "on_event")

func alert() -> void:
	var r = randf()
	if r > 0.666:
		stream = _alert1
	elif r > 0.333:
		stream = _alert2
	else:
		stream = _alert3
	play(0)

func on_event(tag:String) -> void:
	if tag == "pain":
		print("Pain!")
		stream = _pain
		play(0)
	elif tag == "alert":
		print("Alert!")
		alert()