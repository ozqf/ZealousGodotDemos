extends Node3D

@export var id:String = ""
@export var targetId:String = ""

var _targets:PackedStringArray = PackedStringArray()

func _ready() -> void:
	self.connect("body_entered", _on_body_entered)
	
	_targets = targetId.split(",", false)

func _on_body_entered(_body) -> void:
	Game.broadcast_trigger_event(_targets, "trigger_volume", {})
	self.queue_free()
	pass
