extends Node

var _limb_segment_t = preload("res://prefabs/bosses/smatter_limb_segment.tscn")

onready var _root:Spatial = $root
onready var _tip:Spatial = $tip
onready var _nodes:Spatial = $nodes

var _moveWeight:float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	for _i in range(0, 8):
		var segment = _limb_segment_t.instance()
		_nodes.add_child(segment)
	_position_nodes()

func _position_nodes() -> void:
	var origin:Vector3 = _root.global_transform.origin
	var dest:Vector3 = _tip.global_transform.origin
	#print("Limb from " + str(origin) + " to " + str(dest))
	var numSegments:int = _nodes.get_child_count()
	for i in range (0, numSegments):
		var weight:float = float(i) / float(numSegments)
		var pos:Vector3 = origin.linear_interpolate(dest, weight)
		var segment = _nodes.get_child(i)
		segment.global_transform.origin = pos
	pass

func _animate(delta:float) -> void:
	_moveWeight += delta
	var weight:float = sin(_moveWeight)
	
	pass

func _process(delta):
	_animate(delta)
	_position_nodes()
	pass
