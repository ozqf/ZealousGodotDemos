extends Node
class_name Entity

var _snapshot = null
var _id:int = 0

func _enter_tree():
	_id = Snapshot.register_entity(self)

func _exit_tree():
	pass
