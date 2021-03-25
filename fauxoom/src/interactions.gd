class_name Interactions

const WORLD:int = (1 << 0)
const ACTORS:int = (1 << 1)
const PROJECTILES:int = (1 << 2)
const PLAYER:int = (1 << 3)
const TRIGGERS:int = (1 << 4)
const ITEMS:int = (1 << 5)
const ACTOR_BARRIER:int = (1 << 6)
const PLAYER_BARRIER:int = (1 << 7)
const DEBRIS:int = (1 << 8)

const EDITOR_GEOMETRY:int = (1 << 19)

static func get_enemy_prj_mask() -> int:
	return (WORLD | PLAYER)

static func get_player_prj_mask() -> int:
	return (WORLD | ACTORS)

static func hitscan_hit(_hitInfo:HitInfo, _hitScanResult:Dictionary) -> void:
	if _hitScanResult.collider.has_method("hit"):
		_hitScanResult.collider.hit(_hitInfo)

static func triggerTargets(tree:SceneTree, targetNameString:String) -> void:
	var tokens = ZqfUtils.tokenise(targetNameString)
	var numTokens:int = tokens.size()
	for _i in range(0, numTokens):
		tree.call_group(Groups.ENTS_GROUP_NAME, Groups.ENTS_FN_TRIGGER_ENTITIES, tokens[_i])
