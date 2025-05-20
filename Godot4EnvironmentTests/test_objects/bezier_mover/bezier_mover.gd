extends Node3D

static func quadratic_bezier(a:Vector3, b:Vector3, c:Vector3, t:float) -> Vector3:
	var q0:Vector3 = a.lerp(b, t)
	var q1:Vector3 = b.lerp(c, t)
	var r:Vector3 = q0.lerp(q1, t)
	return r

var _pathNode:Node3D = null

var _index:int = 1
var _moveTick:float = 0.0
var _moveTime:float = 1.0

func _ready() -> void:
	_pathNode = get_parent().get_node_or_null("path") as Node3D

func _process(_delta:float) -> void:
	if _pathNode == null:
		self.queue_free()
		return
	_moveTick += _delta
	if _moveTick >= _moveTime:
		_index += 1
		_moveTick -= _moveTime
	var nodes = _pathNode.get_children()
	var num:int = nodes.size()
	var a:Node3D = nodes[_index % num]
	var b:Node3D = a.get_child(0)
	var c:Node3D = nodes[(_index + 1) % num]
	var t:float = clampf(_moveTick / _moveTime, 0, 1.0)
	var pos:Vector3 = quadratic_bezier(a.global_position, b.global_position, c.global_position, t)
	self.global_position = pos
