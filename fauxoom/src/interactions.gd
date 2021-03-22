class_name Interactions

static func hitscan_hit(_hitInfo:HitInfo, _hitScanResult:Dictionary) -> void:
	if _hitScanResult.collider.has_method("hit"):
		_hitScanResult.collider.hit(_hitInfo)

static func triggerTargets(tree:SceneTree, targetNameString:String) -> void:
	var tokens = ZqfUtils.tokenise(targetNameString)
	var numTokens:int = tokens.size()
	for _i in range(0, numTokens):
		tree.call_group(Groups.ENTS_GROUP_NAME, Groups.ENTS_FN_TRIGGER_ENTITIES, tokens[_i])
