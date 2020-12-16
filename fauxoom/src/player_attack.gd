extends Node
class_name PlayerAttack

var _prefab_impact = preload("res://prefabs/bullet_impact.tscn")

var _launchNode:Spatial = null
var _parentBody:PhysicsBody = null
var _active:bool = false
var _tick:float = 0

func init_attack(launchNode:Spatial, ignoreBody:PhysicsBody) -> void:
	_launchNode = launchNode
	_parentBody = ignoreBody

func set_attack_enabled(flag:bool) -> void:
	_active = flag

func _fire() -> void:
	var result = ZqfUtils.quick_hitscan3D(_launchNode, 1000, [_parentBody], -1)
	if result:
		print("HIT at " + str(result.position))
		# result.collider etc etc
		var impact:Spatial = _prefab_impact.instance()
		var root:Node = get_tree().get_current_scene()
		root.add_child(impact)
		var t = impact.global_transform
		t.origin = result.position
		impact.global_transform = t
	pass

func _process(_delta:float) -> void:
	if _tick >= 0:
		_tick -= _delta
		return
	if !_active:
		return
	
	if Input.is_action_pressed("attack_1"):
		_tick = 0.1
		_fire()
	
