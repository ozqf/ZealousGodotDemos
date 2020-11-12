extends Node
class_name Life

export var health:int = 100
var _dead:bool = false
signal on_death

func take_hit(dmg:int):
	if _dead:
		return
	health -= dmg
	if (health <= 0):
		self.emit_signal("on_death")
