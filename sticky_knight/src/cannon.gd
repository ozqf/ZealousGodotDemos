extends KinematicBody2D
class_name Cannon

var _projectile_prefab = preload("res://prefabs/projectile.tscn")

export var refireRate:float = 1.5
var _tick:float = 0

func _ready():
	if refireRate < 0.1:
		refireRate = 0.1

func _process(_delta:float):
	if _tick <= 0:
		_tick = refireRate
		var prj:Projectile = _projectile_prefab.instance()
		var parent = get_tree().get_current_scene()
		parent.add_child(prj)
		prj.launch(self, position, rotation, 250, game.TEAM_ENEMY)
	else:
		_tick -= _delta
