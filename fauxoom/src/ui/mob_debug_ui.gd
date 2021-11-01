extends Label

var _debugMob = null

func _ready() -> void:
	add_to_group(Groups.ENTS_GROUP_NAME)

func on_set_debug_mob(mob) -> void:
	print("Setting debug mob to " + mob.name)
	_debugMob = mob

func _process(_delta:float) -> void:
	if _debugMob == null:
		return
	if is_instance_valid(_debugMob):
		var txt:String = "Debugging " + _debugMob.name + "\n"
		txt += _debugMob.get_debug_text()
		text = txt
	else:
		text = ""
		_debugMob = null
	
