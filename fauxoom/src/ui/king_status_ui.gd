extends Control

@onready var _waveCount:Label = $wave_count_label
@onready var _mobsLabel:Label = $mob_stats_label
@onready var _totalSeconds:Label = $time_label

func _ready() -> void:
	self.visible = false
	self.add_to_group(Groups.GAME_GROUP_NAME)

func game_on_king_status_update(status:KingStatus) -> void:
	self.visible = true
	var waveStr:String = "WAVE: " + str(status.waveCount + 1)
	_waveCount.text = waveStr
	_totalSeconds.text = "TIME: " + ZqfUtils.time_string_from_seconds(status.totalEventSeconds)

	var mobsStr:String = ""
	if status.waveMobsTotal == 0:
		_mobsLabel.visible = false
	else:
		_mobsLabel.visible = true
		var mobsPercentage:float = float(float(status.waveMobsKilled) / float(status.waveMobsTotal))
		mobsPercentage *= 100.0
		mobsStr += str(status.waveMobsKilled) + " / " + str(status.waveMobsTotal)
		mobsStr += " (" + str(int(mobsPercentage)) + "%)"
		_mobsLabel.text = mobsStr

	pass
