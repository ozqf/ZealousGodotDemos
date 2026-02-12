extends Area3D
class_name HurtboxDelegate

var _subject = null

func _ready() -> void:
    _subject = self.get_parent()

func set_subject(newSubject) -> void:
    assert(newSubject != null)
    assert(_subject.has_method("hurt"))
    _subject = newSubject

func hurt(atk:AttackInfo) -> int:
    if (atk == null):
        return Interactions.HIT_IGNORE
    assert(_subject != null)
    return _subject.hurt(atk)
