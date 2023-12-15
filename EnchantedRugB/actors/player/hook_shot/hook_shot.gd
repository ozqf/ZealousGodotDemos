extends Node3D
class_name HookShot

const STATE_IDLE:int = 0
const STATE_GRAPPLE_POINT:int = 1
const STATE_GRAB:int = 2

@onready var _tether:Node3D = $tether_display

#var _isAttached:bool = false
var _hookState:int = STATE_IDLE

func is_attached() -> bool:
	return _hookState == STATE_GRAPPLE_POINT

func attach_to_grapple(pos:Vector3) -> void:
	_hookState = STATE_GRAPPLE_POINT
	self.global_position = pos
	self.visible = true

func grab_object(grabbed) -> void:
	pass

func refresh_tether(source:Transform3D) -> void:
	_tether.look_at(source.origin)
	var newScale:Vector3 = Vector3(1, 1, global_position.distance_to(source.origin))
	_tether.scale = newScale

func release() -> void:
	_hookState = STATE_IDLE
	self.visible = false

func update_input(_input:PlayerInput) -> void:
	_input.hookState = _hookState
	_input.hookPosition = self.global_position
	pass
