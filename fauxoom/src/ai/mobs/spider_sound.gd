extends MobSound

var _shoot:AudioStream = preload("res://assets/sounds/frenzy/Frenzy_On_Start.wav")
var _attack:AudioStream = preload("res://assets/sounds/mob/spider/spider_alert.wav")
var _alert:AudioStream = preload("res://assets/sounds/mob/spider/spider_alert.wav")
var _pain:AudioStream = preload("res://assets/sounds/mob/monster_pain.wav")
var _death:AudioStream = preload("res://assets/sounds/mob/spider/spider_death.wav")

func on_event(tag:String, _index:int) -> void:
	if tag == "shoot":
		play_equipment(_shoot)
	elif tag == "windup":
		play_voice(_attack)
	elif tag == "pain":
		play_voice(_pain)
	elif tag == "death":
		play_voice(_death)
	elif tag == "gib":
		play_voice(_death)
	elif tag == "alert":
		play_voice(_alert)
