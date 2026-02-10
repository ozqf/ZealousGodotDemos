extends Area3D

enum EventType
{
	EndOfLevel
}

@export var eventType:EventType = EventType.EndOfLevel

func _ready() -> void:
	self.connect("body_entered", _on_body_entered)
	pass

func _on_body_entered(body) -> void:
	match eventType:
		EventType.EndOfLevel:
			Game.end_level()
	pass
