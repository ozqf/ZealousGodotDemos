extends Area3D

func _ready() -> void:
	self.connect("body_entered", _on_body_entered)

func _on_body_entered(_node) -> void:
	if !Interactions.get_actor_category(_node) == Interactions.ACTOR_CATEGORY_PLAYER_AVATAR:
		return
	self.get_tree().call_group(Interactions.GROUP_ACTORS, Interactions.FN_ACTOR_TRIGGER, "")
	set_deferred("monitoring", false)

func restore(dict:Dictionary) -> void:
	var t:Transform3D = ZqfUtils.Transform3D_from_dict(dict.xform)
	self.global_transform = t
