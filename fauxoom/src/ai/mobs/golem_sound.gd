extends MobSound

var _shoot:AudioStream = preload("res://assets/sounds/frenzy/Frenzy_On_Start.wav")
var _attack:AudioStream = preload("res://assets/sounds/mob/golem/golem_attack.wav")
var _alert:AudioStream = preload("res://assets/sounds/mob/golem/golem_alert.wav")
var _pain:AudioStream = preload("res://assets/sounds/mob/golem/golem_pain.wav")
var _death:AudioStream = preload("res://assets/sounds/mob/golem/golem_death.wav")

func on_event(tag:String, _index:int) -> void:
	print("Golem sound - " + tag)
	if tag == "shoot":
		stream = _shoot
		play(0)
	elif tag == "windup":
		stream = _attack
		play(0)
	elif tag == "pain":
		stream = _pain
		play(0)
	elif tag == "death":
		stream = _death
		play(0)
	elif tag == "gib":
		stream = _death
		play(0)
	elif tag == "alert":
		stream = _alert
		play(0)
