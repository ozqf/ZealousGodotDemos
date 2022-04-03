extends KinematicBody

func _process(_delta:float) -> void:
	var plyr:Dictionary = AI.get_player_target()
	if !plyr:
		return
