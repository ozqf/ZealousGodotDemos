extends AnimationPlayer
class_name AnimationEmitter

const EVENT_RIGHT_WEAPON_ON:String = "right_weapon_on"
const EVENT_RIGHT_WEAPON_OFF:String = "right_weapon_off"

signal animation_event()

func right_weapon_on() -> void:
	self.emit_signal("animation_event", EVENT_RIGHT_WEAPON_ON)

func right_weapon_off() -> void:
	self.emit_signal("animation_event", EVENT_RIGHT_WEAPON_OFF)
