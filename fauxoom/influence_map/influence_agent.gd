extends Spatial

onready var startOn:bool = true

var _on:bool = false

func _enter_tree():
	get_tree().call_group(Groups.INFLUENCE_GROUP, Groups.INFLUENCE_FN_ADD, self)

func _exit_tree():
	get_tree().call_group(Groups.INFLUENCE_GROUP, Groups.INFLUENCE_FN_REMOVE, self)
