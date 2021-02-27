class_name Interactions

static func hitscan_hit(_hitInfo:HitInfo, _hitScanResult:Dictionary) -> void:
	if _hitScanResult.collider.has_method("hit"):
		_hitScanResult.collider.hit(_hitInfo)
