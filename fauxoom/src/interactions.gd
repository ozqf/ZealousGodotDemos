class_name Interactions

const PLAYER_RESERVED_ID:int = 1

# collision layer numbers
const WORLD_LAYER:int = 0
const ACTORS_LAYER:int = 1
const PROJECTILES_LAYER:int = 2
const PLAYER_LAYER:int = 3
const TRIGGERS_LAYER:int = 4
const ITEMS_LAYER:int = 5
const ACTOR_BARRIER_LAYER:int = 6
const PLAYER_BARRIER_LAYER:int = 7
const DEBRIS_LAYER:int = 8
const INTERACTIVE_LAYER:int = 9
const CORPSE_LAYER:int = 10
const PROJECTILE_RIGIDBODY:int = 11

const EXPLOSION_CHECK_LAYER:int = 18
const EDITOR_GEOMETRY_LAYER:int = 19

# collision layer bit masks
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

const EXPLOSION_CHECK:int = (1 << 18)
const EDITOR_GEOMETRY:int = (1 << 19)

# teams for when objects of the same layer choose to hurt each other
const TEAM_NONE:int = 0
const TEAM_ENEMY:int = 1
const TEAM_PLAYER:int = 2
const TEAM_NON_COMBATANT:int = 3

const DAMAGE_TYPE_NONE:int = 0
const DAMAGE_TYPE_EXPLOSIVE:int = 1
const DAMAGE_TYPE_SAW:int = 2
const DAMAGE_TYPE_PUNCH:int = 3
const DAMAGE_TYPE_SIEGE:int = 4
const DAMAGE_TYPE_PLASMA:int = 5
const DAMAGE_TYPE_SHARPNEL:int = 6
const DAMAGE_TYPE_VOID:int = 7
const DAMAGE_TYPE_SUPER_PUNCH:int = 8
const DAMAGE_TYPE_SAW_PROJECTILE:int = 9
const DAMAGE_TYPE_SLIME:int = 10
const DAMAGE_TYPE_SUPER_RAIL:int = 11

const COMBO_CLASS_NONE:int = 0
const COMBO_CLASS_BULLET:int = 1
const COMBO_CLASS_RAILGUN:int = 2
const COMBO_CLASS_ROCKET:int = 3
const COMBO_CLASS_SHRAPNEL:int = 4
const COMBO_CLASS_PUNCH:int = 5
const COMBO_CLASS_STAKE:int = 6
const COMBO_CLASS_SAWBLADE:int = 7

const HYPER_ACTIVATE_COST:int = 0
const HYPER_ACTIVATE_MINIMUM:int = 0
const HYPER_SAVE_COST:int = 20
const HYPER_COST_PER_TICK:int = 0 #1
const HYPER_COST_TICK_TIME:float = 0.0 #0.25 # 0.125
const HYPER_DURATION:float = 10.0
const HYPER_COOLDOWN_DURATION:float = 0.0

const HYPER_COST_PISTOL:int = 1
const HYPER_COST_SHOTGUN:int = 10
const HYPER_COST_ROCKET:int = 5
const HYPER_COST_PLASMA:int = 20
const HYPER_COST_SAW:int = 10

const MOB_DROP_COUNT:int = 3
const MOB_DROP_COUNT_SUPER_PUNCH:int = 4

const HIT_RESPONSE_NONE:int = -1
const HIT_RESPONSE_ABSORBED:int = -2
const HIT_RESPONSE_PENETRATE:int = -2

const DAMAGE_SUPER_PUNCH:int = 100

static func get_enemy_prj_mask() -> int:
	return (WORLD | PLAYER)

static func get_player_prj_mask() -> int:
	return (WORLD | ACTORS)

static func get_entity_mask() -> int:
	return (ACTORS | PLAYER)

static func get_corpse_hit_mask() -> int:
	return CORPSE

static func get_explosion_check_mask() -> int:
	return (WORLD | EXPLOSION_CHECK)

static func is_obj_a_mob(obj) -> bool:
	if !is_instance_valid(obj):
		return false
	if !obj.has_method("is_mob"):
		return false
	return obj.is_mob()

static func is_ray_hit_a_mob(_hitScanResult:Dictionary) -> bool:
	if !_hitScanResult.collider.has_method("is_mob"):
		return false
	return _hitScanResult.collider.is_mob()

static func is_collider_usable(collider) -> bool:
	if collider == null || !is_instance_valid(collider):
		return false
	return collider.has_method("use_interactive")

static func use_collider(collider, _user) -> bool:
	if collider.has_method("use_interactive"):
		collider.use_interactive(_user)
		return true
	return false

# returns -1 if object had no hit function
static func hitscan_hit(_hitInfo:HitInfo, _hitScanResult:Dictionary) -> int:
	if _hitScanResult.collider.has_method("hit"):
		return _hitScanResult.collider.hit(_hitInfo)
	return HIT_RESPONSE_NONE

# returns -1 if object had no hit function
# returns -2 if object let hit through
static func hit(_hitInfo:HitInfo, collider) -> int:
	if is_instance_valid(collider) && collider.has_method("hit"):
		return collider.hit(_hitInfo)
	return HIT_RESPONSE_NONE

static func triggerTargets(tree:SceneTree, targetNameString:String) -> void:
	if tree == null:
		return
	if targetNameString == null || targetNameString == "":
		return
	# print("Trigger targets - " + targetNameString)
	var tokens = ZqfUtils.tokenise(targetNameString)
	var numTokens:int = tokens.size()
	var msg:String = ""
	var params:Dictionary = ZqfUtils.EMPTY_DICT
	for _i in range(0, numTokens):
		tree.call_group(Groups.ENTS_GROUP_NAME, Groups.ENTS_FN_TRIGGER_ENTITIES, tokens[_i], msg, params)

static func triggerTargetsWithParams(tree:SceneTree, targetNameArray, message:String, params:Dictionary) -> void:
	if tree == null:
		return
	var numTargets:int = targetNameArray.size()
	for _i in range(0, numTargets):
		tree.call_group(Groups.ENTS_GROUP_NAME, Groups.ENTS_FN_TRIGGER_ENTITIES, targetNameArray[_i], message, params)
