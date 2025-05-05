extends Node

@onready var _label:Label = $Label

func _ready() -> void:
	add_to_group(Groups.GAME_GROUP_NAME)

func game_on_king_game_over(info:Dictionary) -> void:
	#GAME OVER
	#WAVES - TOTAL: 14. BEST: 15 (90%)
	#BEST WAVES: 15
	#TIME: 13:24
	# var minutes:int = int(info.seconds / 60.0)
	# var seconds:int = int(info.seconds) % 60
	# var timeStr:String = str(minutes) + ":" + str(seconds)
	var timeStr:String = ZqfUtils.time_string_from_seconds(info.seconds)
	print("King mode ended: wave completed " + str(info.waves) + " total time: " + timeStr)
	var txt:String = "GAME OVER\nWAVES TOTAL: " + str(info.waves) + "\n"
	txt += "TIME: " + timeStr + "\n"
	_label.text = txt

func game_on_map_change() -> void:
	self.queue_free()
