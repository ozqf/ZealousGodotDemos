extends Spatial

var _limb_segment_t = preload("res://prefabs/bosses/smatter_limb_segment.tscn")

onready var _tip:Spatial = $tip
onready var _nodes:Spatial = $nodes

export var length:int = 8
var _moveWeight:float = 0.0

func _ready():
	if length <= 0:
		length = 8
	for _i in range(0, length * 2):
		var segment = _limb_segment_t.instance()
		_nodes.add_child(segment)
	_animate(-1)
	_position_nodes()

func _position_nodes() -> void:
	var origin:Vector3 = Vector3() # transform.origin
	var dest:Vector3 = _tip.transform.origin
	#print("Limb from " + str(origin) + " to " + str(dest))
	var numSegments:int = _nodes.get_child_count()
	for i in range (0, numSegments):
		var weight:float = float(i) / float(numSegments)
		var pos:Vector3 = origin.linear_interpolate(dest, weight)
		var segment = _nodes.get_child(i)
		segment.transform.origin = pos
	pass

func _animate(delta:float) -> void:
	_moveWeight += (delta * 2.0)
	var weight:float = sin(_moveWeight)
	var offset:float = weight * 5.0
	var up:Vector3 = transform.basis.y
	var left:Vector3 = transform.basis.x
	up = Vector3.UP
	left = Vector3.LEFT
	# print("Weight " + str(weight) + " offset " + str(offset) + " up " + str(up))
	var pos:Vector3 = transform.origin
	pos += up * length
	pos += left * offset
	# pos.y += 8.0
	# pos.x += offset
	_tip.transform.origin = pos
	pass

func _process(delta):
	_animate(delta)
	_position_nodes()
	pass
