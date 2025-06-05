class_name Interactions

const GROUP_ACTORS:String = "actors"
# signature (msg:String)
const FN_ACTOR_TRIGGER:String = "actor_trigger"

const ACTOR_CATEGORY_NONE:int = 0
const ACTOR_CATEGORY_PLAYER_AVATAR:int = 1
const ACTOR_CATEGORY_MOB:int = 2

static func get_actor_category(node) -> int:
	if node == null:
		return ACTOR_CATEGORY_NONE
	if !node.has_method("get_actor_category"):
		return ACTOR_CATEGORY_NONE
	return node.get_actor_category()
