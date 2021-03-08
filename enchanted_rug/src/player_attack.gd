extends Node

var _projectile_t = preload("res://prefabs/projectile.tscn")

var _body:Spatial = null
var _refireTick:float = 0

func _ready():
	_body = get_parent()

func _fire() -> void:
	var pos:Vector3 = _body.global_transform.origin
	var forward:Vector3 = -_body.global_transform.basis.z
	var prj = _projectile_t.instance()
	get_tree().get_current_scene().add_child(prj)
	prj.launch(pos, forward)

func _process(_delta:float) -> void:
	if _refireTick <= 0:
		if Input.is_action_pressed("attack_1"):
			_refireTick = 0.1
			_fire()
	else:
		_refireTick -= _delta
