extends Spatial

onready var _off:Spatial = $off
onready var _on:Spatial = $on
onready var _shape:CollisionShape = $CollisionShape

export var on:bool = false

func _set_on(flag:bool) -> void:
	on = flag
	_off.visible = !on
	_on.visible = on
	_shape.disabled = on

func use() -> void:
	if !on:
		_set_on(true)
