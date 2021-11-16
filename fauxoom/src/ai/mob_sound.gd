extends AudioStreamPlayer3D

var _alert1:AudioStream = preload("res://assets/sounds/mob/punk/punk_alert_1.wav")
var _alert2:AudioStream = preload("res://assets/sounds/mob/punk/punk_alert_2.wav")
var _alert3:AudioStream = preload("res://assets/sounds/mob/punk/punk_alert_3.wav")

var _pain:AudioStream = preload("res://assets/sounds/mob/punk/punk_pain.wav")

var _death1:AudioStream = preload("res://assets/sounds/mob/punk/punk_death_1.wav")
var _death2:AudioStream = preload("res://assets/sounds/mob/punk/punk_death_2.wav")
var _death3:AudioStream = preload("res://assets/sounds/mob/punk/punk_death_3.wav")

var shoot:AudioStream = preload("res://assets/sounds/weapon/pistol_fire.wav")

var _slop:AudioStream = preload("res://assets/sounds/impact/slop.wav")

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

func death() -> void:
	var r = randf()
	if r > 0.666:
		stream = _death1
	elif r > 0.333:
		stream = _death2
	else:
		stream = _death3
	play(0)

func gib() -> void:
	stream = _slop
	play(0)

func on_event(tag:String) -> void:
	if tag == "shoot":
		stream = shoot
		play(0)
	elif tag == "pain":
		stream = _pain
		play(0)
	elif tag == "death":
		death()
	elif tag == "gib":
		gib()
	elif tag == "alert":
		alert()
