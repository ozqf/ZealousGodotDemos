#@implements IHittable
extends Node
class_name HitDelegate

var _subject:Node = null

func set_subject(newSubject:Node) -> void:
	_subject = newSubject

func get_team_id() -> int:
	if _subject != null:
		return _subject.get_team_id()
	return get_parent().get_team_id()

func hit(_hitInfo:HitInfo) -> int:
	if _subject != null:
		return _subject.hit(_hitInfo)
	return get_parent().hit(_hitInfo)
