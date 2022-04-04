extends MobSound

var _alert1:AudioStream = preload("res://assets/sounds/mob/punk/punk_alert_1.wav")
var _alert2:AudioStream = preload("res://assets/sounds/mob/punk/punk_alert_2.wav")
var _alert3:AudioStream = preload("res://assets/sounds/mob/punk/punk_alert_3.wav")

var _pain:AudioStream = preload("res://assets/sounds/mob/punk/punk_pain.wav")

var _death1:AudioStream = preload("res://assets/sounds/mob/punk/punk_death_1.wav")
var _death2:AudioStream = preload("res://assets/sounds/mob/punk/punk_death_2.wav")
var _death3:AudioStream = preload("res://assets/sounds/mob/punk/punk_death_3.wav")

var _shoot:AudioStream = preload("res://assets/sounds/weapon/pistol_fire.wav")

var _slop:AudioStream = preload("res://assets/sounds/impact/slop.wav")

func alert() -> void:
	var r = randf()
	if r > 0.666:
		play_voice(_alert1)
	elif r > 0.333:
		play_voice(_alert2)
	else:
		play_voice(_alert3)

func death() -> void:
	var r = randf()
	if r > 0.666:
		play_voice(_death1)
	elif r > 0.333:
		play_voice(_death2)
	else:
		play_voice(_death3)

func gib() -> void:
	play_voice(_slop)

func on_event(tag:String, _index:int) -> void:
	if tag == "shoot":
		play_equipment(_shoot)
	elif tag == "windup":
		alert()
	elif tag == "pain":
		play_voice(_pain)
	elif tag == "death":
		death()
	elif tag == "gib":
		gib()
	elif tag == "alert":
		alert()
