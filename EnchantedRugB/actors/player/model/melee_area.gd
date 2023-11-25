extends Node

signal on_melee_hit(attackerArea, victimArea)

func _ready():
	self.connect("area_entered", _on_area_entered)

func _on_area_entered(area:Area3D) -> void:
	self.emit_signal("on_melee_hit", self, area)
