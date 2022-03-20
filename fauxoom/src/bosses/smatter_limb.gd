extends Spatial

var _limb_segment_t = preload("res://prefabs/bosses/smatter_limb_segment.tscn")

onready var _tip:Spatial = $tip
onready var _nodes:Spatial = $nodes

export var length:int = 8
var _moveWeight:float = 0.0

var _time:float = 0.0

func _ready():
	if length <= 0:
		length = 8
	for _i in range(0, length * 4):
		var segment = _limb_segment_t.instance()
		_nodes.add_child(segment)
	_animate(0)
	_position_nodes()

func _calc_limit_promxity(count:float, total:float) -> float:
	var half:float = total * 0.5
	if count > half:
		count = total - count
	return count / half

func _position_nodes() -> void:
	# in local coordinates:
	
	# original, causes wave to originate from tip
	#var origin:Vector3 = Vector3() # transform.origin
	#var dest:Vector3 = _tip.transform.origin
	
	# reversed: wave originates from root
	var origin:Vector3 = _tip.transform.origin
	var dest:Vector3 = Vector3()
	
	var left:Vector3 = _tip.transform.basis.x;
	#print("Limb from " + str(origin) + " to " + str(dest))
	var numSegments:int = _nodes.get_child_count()
	
	# offsetting wave
	var frequency:float = 4
	var offsetStep:float = PI / (float(numSegments) * (1.0 / frequency))
	
	var time:float = _time - floor(_time)
	var offsetOrigin:float = float(numSegments) * time
	#print("Offset origin: " + str(offsetOrigin))
	
	#for i in range (numSegments - 1, -1, -1):
	for i in range (0, numSegments):
		var segment = _nodes.get_child(i)
		var weight:float = float(i) / float(numSegments)
		var pos:Vector3 = origin.linear_interpolate(dest, weight)
		var offsetWeight:float = cos((float(i) + offsetOrigin) * offsetStep)
		offsetWeight *= _calc_limit_promxity(i, numSegments)
		var offset:Vector3 = (left * offsetWeight)
		pos += offset
		
		segment.transform.origin = pos

	pass

func _animate(delta:float) -> void:
	_moveWeight += (delta * 1.0)
	#_moveWeight = 0.0
	var weight:float = sin(_moveWeight)
	#weight = 0.0
	var offset:float = weight * 1.0
	var up:Vector3 = transform.basis.y
	var left:Vector3 = transform.basis.x
	up = Vector3.UP
	left = Vector3.LEFT
	# print("Weight " + str(weight) + " offset " + str(offset) + " up " + str(up))
	var pos:Vector3 = Vector3()
	pos += up * length
	pos += left * offset
	# pos.y += 8.0
	# pos.x += offset
	_tip.transform.origin = pos
	pass

func _process(delta):
	_time += (delta * 0.25)
	_animate(delta)
	_position_nodes()
	pass
