extends Node3D
class_name SoundFXManager

var _impact_s:AudioStream = preload("res://assets/sounds/impact/Bullet_Impact_1.wav")

var _quickSfx_t = preload("res://prefabs/sounds/quick_sound_3d.tscn")

func spawn_impact(pos:Vector3) -> void:
	var obj = _quickSfx_t.instance()
	self.add_child(obj)
	obj.quick_play(pos, _impact_s)
