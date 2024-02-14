extends MeshInstance3D

var _matIdle = preload("res://actors/components/mood_aura/mat_mood_idle.tres")
var _matStaggered = preload("res://actors/components/mood_aura/mat_mood_staggered.tres")
var _matGuarding = preload("res://actors/components/mood_aura/mat_mood_guarding.tres")
var _matAttacking = preload("res://actors/components/mood_aura/mat_mood_attacking.tres")
var _matParried = preload("res://actors/components/mood_aura/mat_mood_parried.tres")

var _aura:GameCtrl.MoodAura = GameCtrl.MoodAura.Idle

func _ready() -> void:
	refresh(GameCtrl.MoodAura.Idle)
	var mobBase:MobBase = get_parent().get_parent() as MobBase
	if mobBase == null:
		print("Mood aura couldn't find mob base")
		return
	mobBase.connect("MobStateChange", on_mob_state_change)

func on_mob_state_change(_newMobState, _prevMobState, _mobBase:MobBase) -> void:
	var mat
	match _newMobState:
		GameCtrl.MobState.Staggered:
			mat = _matStaggered
		GameCtrl.MobState.Swinging:
			mat = _matAttacking
		GameCtrl.MobState.StaticGuard:
			mat = _matGuarding
		GameCtrl.MobState.Parried:
			mat = _matParried
		GameCtrl.MobState.Launched:
			mat = _matStaggered
		GameCtrl.MobState.Juggled:
			mat = _matStaggered
		_:
			mat = _matIdle
	self.set_surface_override_material(0, mat)
	pass

func refresh(_newMood:GameCtrl.MoodAura) -> void:
	_aura = _newMood


