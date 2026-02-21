extends Node3D
class_name Arena

enum State
{
	AwaitingInit,
	Idle,
	Running,
	Complete,
	Broken
}

@export var debug:bool = false

var _state:State = State.AwaitingInit
var _startArea:Area3D = null
var _sequence:ArenaSequence = null
var _forcefields:Array[PlayerBarrier] = []

var _tick:int = 0

func _ready() -> void:
	pass

func _setup() -> void:
	if _state != State.AwaitingInit:
		return
	var worldNodesToRemove:Array[Node] = []
	var srcNode:Node3D = self
	for n in srcNode.get_children():
		var barrier:PlayerBarrier = n as PlayerBarrier
		if barrier != null:
			_forcefields.push_back(barrier)
			worldNodesToRemove.push_back(n)
			continue
		var area:Area3D = n as Area3D
		if area != null && _startArea == null:
			_startArea = area
			print("Arena found start area")
			continue
		var seq:ArenaSequence = n as ArenaSequence
		if seq != null && _sequence == null:
			_sequence = seq
			print("Arena found sequence node")
			continue
	for n in worldNodesToRemove:
		srcNode.remove_child(n)
	print("Arena found " + str(_forcefields.size()) + " forcefields")
	_state = State.Idle

func _start() -> void:
	_state = State.Running
	for forceField in _forcefields:
		self.add_child(forceField)
	
	if _sequence != null:
		_sequence.start()

func _finish() -> void:
	_state = State.Complete
	for field in _forcefields:
		self.remove_child(field)

func _physics_process(_delta:float) -> void:
	_tick += 1
	match (_state):
		State.Running:
			if _tick % 3 == 0 && (_sequence == null || _sequence.tick()):
				_finish()
				return
			pass
		State.AwaitingInit:
			_setup()
		State.Idle:
			if _startArea == null:
				_state = State.Broken
				print("Arena has no start area")
				return
			if _startArea.get_overlapping_bodies().size() > 0:
				_start()
	#
