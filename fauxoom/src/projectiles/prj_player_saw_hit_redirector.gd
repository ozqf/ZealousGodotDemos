extends Node

var _subject = null

func set_subject(newSubject) -> void:
	print("Hit redirector - set subject")
	_subject = newSubject

func hit(_hitInfo:HitInfo) -> int:
	if _subject == null:
		print("hit redirector has no subject")
		return Interactions.HIT_RESPONSE_NONE
	return _subject.hit(_hitInfo)

func item_projectile_gather(newParent) -> void:
	if _subject == null:
		print("hit redirector has no subject")
		return
	_subject.item_projectile_gather(newParent)
	