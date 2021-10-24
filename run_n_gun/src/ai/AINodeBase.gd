extends AINode
class_name AINodeBase

var parentNode:AINode = null
var children = []
var numChildren:int = 0

func _ready() -> void:
	# fs I can't even reference MY OWN TYPE without creating a
	# cyclic reference... this stuff should be in AINode class
	# but hoisted up to this sub-class because of self reference here:
	if get_parent() is AINode:
		parentNode = get_parent() as AINode
	for _i in range(0, self.get_child_count()):
		var child = self.get_child(_i)
		if child is AINode:
			children.push_back(child)
	numChildren = children.size()

func call_first_child(info:AIInfo) -> int:
	if numChildren == 0:
		if info.verbose:
			print(name + " has no children to call - success returned")
		return SUCCESS
	if info.verbose:
		print(name + " calling first child " + children[0].name)
	return children[0].tick(info)
