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

@onready var _actions:Node3D = $actions
@onready var _world:Node3D = $world

var _state:State = State.AwaitingInit
var _startArea:Area3D = null
var _forcefields:Array[PlayerBarrier] = []

var _actionIndex:int = 0
var _tick:int = 0

func _ready() -> void:
	pass

func _setup() -> void:
	if _state != State.AwaitingInit:
		return
	var worldNodesToRemove:Array[Node] = []
	for n in _world.get_children():
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
	for n in worldNodesToRemove:
		_world.remove_child(n)
	print("Arena found " + str(_forcefields.size()) + " forcefields")
	_state = State.Idle

func _start() -> void:
	_state = State.Running
	for forceField in _forcefields:
		_world.add_child(forceField)
	
	for n in _actions.get_children():
		if n.name.begins_with("mob_spawn"):
			var t:Transform3D = n.global_transform
			Game.spawn_fodder(t, n)
			pass

func _finish() -> void:
	_state = State.Complete
	for field in _forcefields:
		_world.remove_child(field)

func _check_actions_finished() -> void:
	var runningNodes:int = 0
	for n in _actions.get_children():
		if n.name.begins_with("mob_spawn"):
			if n.get_child_count() > 1:
				runningNodes += 1
	if runningNodes == 0:
		_finish()

func _physics_process(_delta:float) -> void:
	_tick += 1
	match (_state):
		State.Running:
			if _tick % 3 == 0:
				_check_actions_finished()
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
	#var n:Node3D = _actions.get_child(_actionIndex)
	#var area:Area3D = n as Area3D
	
	
