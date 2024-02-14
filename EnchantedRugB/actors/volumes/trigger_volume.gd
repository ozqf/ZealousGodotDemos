extends Area3D
class_name TriggerVolume

signal triggered(triggerVolumeInstance, triggeringNode)

@onready var _shape:CollisionShape3D = $CollisionShape3D

func _ready():
	self.connect("body_entered", _on_body_entered)
	self.connect("area_entered", _on_area_entered)

func set_active(_flag:bool) -> void:
	_shape.disabled = !_flag

func _on_area_entered(_area:Area3D) -> void:
	self.emit_signal("triggered", self, _area)

func _on_body_entered(body) -> void:
	self.emit_signal("triggered", self, body)
