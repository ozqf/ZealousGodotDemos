extends MeshInstance3D

var _matIdle = preload("res://actors/components/mood_aura/mat_mood_idle.tres")

var _aura:GameCtrl.MoodAura = GameCtrl.MoodAura.Idle

func _ready() -> void:
	refresh(GameCtrl.MoodAura.Idle)

func refresh(_newMood:GameCtrl.MoodAura) -> void:
	_aura = _newMood


