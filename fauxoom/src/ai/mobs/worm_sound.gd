extends MobSound

var _alert:AudioStream = preload("res://assets/sounds/mob/worm/worm_alert.wav")
var _attack:AudioStream = preload("res://assets/sounds/mob/worm/worm_attack.wav")
var _pain:AudioStream = preload("res://assets/sounds/mob/monster_pain.wav")
var _death:AudioStream = preload("res://assets/sounds/mob/worm/worm_death.wav")


func on_event(tag:String, _index:int) -> void:
	if tag == "windup":
		play_voice(_attack)
		play_equipment(_attack)
	elif tag == "pain":
		play_voice(_pain)
	elif tag == "death":
		play_voice(_death)
	elif tag == "gib":
		play_voice(_death)
	elif tag == "alert":
		play_voice(_alert)
