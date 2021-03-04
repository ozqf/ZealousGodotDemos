extends Camera
class_name AttachableCamera

var _worldParent:Spatial = null
var _attachParent:Spatial = null

func _ready() -> void:
	_worldParent = get_parent()

func attach_to(newParent:Spatial) -> void:
	if _attachParent != null:
		detach()
	_attachParent = newParent
	# reset local position
	_worldParent.remove_child(self)
	_attachParent.add_child(self)
	transform = Transform.IDENTITY
	var _f = _attachParent.connect("tree_exiting", self, "detach")

func detach() -> void:
	if _attachParent == null:
		return
	var t:Transform = _attachParent.global_transform
	_attachParent.remove_child(self)
	_attachParent.disconnect("tree_exiting", self, "detach")
	_attachParent = null
	_worldParent.add_child(self)
	global_transform = t
