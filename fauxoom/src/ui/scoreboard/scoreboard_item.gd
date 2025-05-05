extends Node

@onready var _playerName:Label = $player_name
@onready var _waveCount:Label = $wave_count
@onready var _time:Label = $time

func scoreboard_item_init(plyr:String, waves:int, seconds:float) -> void:
	_playerName.text = plyr
	_waveCount.text = str(waves)
	_time.text = ZqfUtils.time_string_from_seconds(seconds)
