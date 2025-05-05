extends Node

@onready var _area:Area3D = $Area
var _bodies = []
var _hitInfo:HitInfo
var _frames:int = 0

func _ready() -> void:
	_hitInfo = Game.new_hit_info()
	_hitInfo.damage = 1
	_hitInfo.direction = Vector3.UP
	_hitInfo.damageType = Interactions.DAMAGE_TYPE_SLIME
	_area.connect("body_entered", self, "_on_body_entered")
	_area.connect("body_exited", self, "_on_body_exited")

func _on_body_entered(body) -> void:
	if body is Player:
		body.set_over_slime(true)
		_bodies.push_back(body)

func _on_body_exited(body) -> void:
	if body is Player:
		body.set_over_slime(false)
		var i:int = _bodies.find(body)
		_bodies.remove(i)

func _physics_process(_delta) -> void:
	_frames += 1
	if (_frames % 2) != 0:
		return
	for body in _bodies:
		if body is Player:
			Interactions.hit(_hitInfo, body)
	pass
