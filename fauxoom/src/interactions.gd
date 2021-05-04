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
const INTERACTIVE:int = (1 << 9)
const CORPSE:int = (1 << 10)

const EDITOR_GEOMETRY:int = (1 << 19)

const TEAM_NONE:int = 0
const TEAM_ENEMY:int = 1
const TEAM_PLAYER:int = 2
const TEAM_NON_COMBATANT:int = 3

const DAMAGE_TYPE_NONE:int = 0
const DAMAGE_TYPE_EXPLOSIVE:int = 1
const DAMAGE_TYPE_SAW:int = 2
const DAMAGE_TYPE_PUNCH:int = 3
const DAMAGE_TYPE_SIEGE:int = 4

const HIT_RESPONSE_NONE:int = -1
const HIT_RESPONSE_PENETRATE:int = -2

static func get_enemy_prj_mask() -> int:
	return (WORLD | PLAYER)

static func get_player_prj_mask() -> int:
	return (WORLD | ACTORS)

static func get_corpse_hit_mask() -> int:
	return CORPSE

# returns -1 if object had no hit function
static func hitscan_hit(_hitInfo:HitInfo, _hitScanResult:Dictionary) -> int:
	if _hitScanResult.collider.has_method("hit"):
		return _hitScanResult.collider.hit(_hitInfo)
	return HIT_RESPONSE_NONE

# returns -1 if object had no hit function
# returns -2 if object let hit through
static func hit(_hitInfo:HitInfo, collider) -> int:
	if collider.has_method("hit"):
		return collider.hit(_hitInfo)
	return HIT_RESPONSE_NONE

static func triggerTargets(tree:SceneTree, targetNameString:String) -> void:
	if tree == null:
		return
	if targetNameString == null || targetNameString == "":
		return
	print("Trigger targets - " + targetNameString)
	var tokens = ZqfUtils.tokenise(targetNameString)
	var numTokens:int = tokens.size()
	for _i in range(0, numTokens):
		tree.call_group(Groups.ENTS_GROUP_NAME, Groups.ENTS_FN_TRIGGER_ENTITIES, tokens[_i])
