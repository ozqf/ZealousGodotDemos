#@implements IHittable
extends Node

var _subject:Node = null

func set_subject(newSubject:Node) -> void:
	_subject = newSubject

func hit(_hitInfo:HitInfo) -> HitResponseInfo:
	if _subject != null:
		return _subject.hit(_hitInfo)
	return get_parent().hit(_hitInfo)
