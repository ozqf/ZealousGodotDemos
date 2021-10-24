class_name AIInfo

# sigh... so 'activeNode' is an AINode, but I can't reference that class directly because
# that would make a circular dependency between these two classes.
# please hurry up with Godot 4 because this limitation is infuriating for
# anyone who actually wants to use a solid type system...

# Aaaanyway... If an AI node is 'active', that means it needs to run until completion
# then either hand back to its parent or tick the entire tree again
# in theory we pick up from the active node, but I've not figured out how
# to jump to this and resume when in, say, a sequence that needs to hand
# back to its parent node on completion
var activeNode = null

var mob:Node2D

var selfPosition:Vector2 = Vector2()
var targetPosition:Vector2 = Vector2()
var moveTarget:Vector2 = Vector2()
var moveDir:Vector2 = Vector2()
var time:float = 0
var delta:float = 1.0 / 60.0
var frames:int = 0
var verbose:bool = true
