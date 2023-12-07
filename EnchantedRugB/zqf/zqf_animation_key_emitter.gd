extends AnimationPlayer
class_name ZqfAnimationKeyEmitter

signal anim_key_event(keyIndex)

func animation_key_0() -> void:
	self.emit_signal("anim_key_event", 0)

func animation_key_1() -> void:
	self.emit_signal("anim_key_event", 1)

func animation_key_2() -> void:
	self.emit_signal("anim_key_event", 2)

func animation_key_3() -> void:
	self.emit_signal("anim_key_event", 3)
