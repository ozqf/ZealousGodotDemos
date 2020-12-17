extends CanvasLayer
class_name Hud

onready var _ssg:AnimatedSprite = $gun/ssg
var _isShooting:bool = false

func _ready() -> void:
	var _f = _ssg.connect("animation_finished", self, "_on_ssg_animation_finished")

func _on_ssg_animation_finished() -> void:
	if _isShooting:
		_isShooting = false
		_ssg.play("idle")

func on_shoot_ssg() -> void:
	_ssg.play("shoot")
	_isShooting = true
