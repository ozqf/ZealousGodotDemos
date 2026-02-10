extends Node3D
class_name ArenaSequence

enum SequenceType
{
	Linear,
	Parallel
}
@export var sequenceType:SequenceType = SequenceType.Linear

var _actionIndex:int = -1
var _node:Node = null

func start() -> void:
	match sequenceType:
		SequenceType.Parallel:
			for n in get_children():
				_start_node(n)
		SequenceType.Linear, _:
			print("Linear sequence start")
			if self.get_child_count() == 0:
				_actionIndex = -1
				return
			_actionIndex = 0
			var n:Node = get_child(_actionIndex)
			_start_node(n)
			#_node = get_child(_actionIndex)
			
	
	#for n in self.get_children():
	#	if n.name.begins_with("mob_spawn"):
	#		var t:Transform3D = n.global_transform
	#		Game.spawn_fodder(t, n)

func _start_node(n:Node) -> void:
	var seq:ArenaSequence = n as ArenaSequence
	if seq != null:
		seq.start()
		return
	if n.name.begins_with("mob_spawn"):
		var t:Transform3D = n.global_transform
		Game.spawn_fodder(t, n)

func _check_node_finished(n:Node) -> bool:
	var seq:ArenaSequence = n as ArenaSequence
	if seq != null:
		return seq.tick()
	if n.name.begins_with("mob_spawn"):
			if n.get_child_count() > 1:
				return false
	return true

# returns true if finished
func tick() -> bool:
	match sequenceType:
		SequenceType.Parallel:
			for n in self.get_children():
				if !_check_node_finished(n):
					return false
			return true
		SequenceType.Linear, _:
			var n:Node = get_child(_actionIndex)
			if !_check_node_finished(n):
				return false
			_actionIndex += 1
			var numChildren:int = self.get_child_count()
			if _actionIndex >= numChildren:
				_actionIndex = 0
				return true
			n = get_child(_actionIndex)
			_start_node(n)
			return false
	return false
